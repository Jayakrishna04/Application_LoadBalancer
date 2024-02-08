# creation of vpc
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "CloudChamp"
  }

}

# creation of subnet1
resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# creation of subnet2
resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# internetgateway 

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

}

#routeTable

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#subnet association 

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.myrt.id

}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.myrt.id

}

#securitygroup

resource "aws_security_group" "mysg" {
  name   = "websg"
  vpc_id = aws_vpc.myvpc.id


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "WebSG"
  }
}

#creating s3

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

}

#creating ec2

resource "aws_instance" "webserver1" {
  ami                    = var.ec2instance
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata.sh"))

  tags = {
    Name = "Server1111"
  }


}

resource "aws_instance" "webserver2" {
  ami                    = var.ec2instance
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata2.sh"))
  tags = {
    Name = "Server2222"
  }


}

#create Application LoadBalancer

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

# create target group 
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }



}

#create targetGroupAttachment
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

# listnergroup

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }


}

# create output
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name

}