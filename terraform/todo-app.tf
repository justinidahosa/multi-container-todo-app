resource "aws_instance" "todo_server" {
  ami           = "ami-0c02fb55956c7d316" 
  instance_type = "t2.micro"
  key_name      = "my-key"
  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.todo_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              mkdir -p /home/ec2-user/todo
              cd /home/ec2-user/todo
              git clone https://github.com/YOUR_GITHUB_REPO.git .
              docker-compose up -d
              EOF

  tags = {
    Name = "todo-server"
  }
}