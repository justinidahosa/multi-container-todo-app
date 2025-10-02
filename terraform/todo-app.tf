# EC2 Instance
resource "aws_instance" "todo_server" {
  ami                    = "ami-0254b2d5c4c472488"
  instance_type          = "t2.micro"
  key_name               = "my-key"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.todo_sg.id]

  # Attach IAM instance profile for SSM
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  # User data script
  user_data = <<-EOF
#!/bin/bash
set -e

# Log everything to a file for debugging
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting User Data Script ==="

# Update system packages
yum update -y

# Install Git
yum install -y git

# Install Docker
amazon-linux-extras enable docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to Docker group
usermod -aG docker ec2-user

# Install Docker Compose
DOCKER_COMPOSE_VERSION=2.23.0
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Switch to ec2-user home directory
cd /home/ec2-user

# Clone repo if it doesn't exist, otherwise update it
if [ ! -d "multi-container-todo-app" ]; then
  git clone https://github.com/justinidahosa/multi-container-todo-app
else
  cd multi-container-todo-app
  git reset --hard
  git clean -fd
  git pull
fi

cd multi-container-todo-app

# Run Docker Compose as ec2-user to avoid permissions issues
su - ec2-user -c "docker-compose up -d --build"

echo "=== User Data Script Finished ==="
EOF

  tags = {
    Name = "todo-server"
  }
}

# IAM Role for SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach SSM Managed Policy
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for the EC2 role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
