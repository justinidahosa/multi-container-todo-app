resource "aws_security_group" "todo_sg" {
   vpc_id = aws_vpc.my_vpc.id
   
  name        = "todo-sg"
  description = "allows ssh from my ip and listens on port 3000 for http from anywhere"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["104.3.254.193/32"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}