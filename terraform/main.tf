# RESOURCE: VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
}

# RESOURCE: INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

# RESOURCE: SUBNETS
resource "aws_subnet" "sn_pub_az1a" {
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = "us-east-1a"
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sn_pub_az1b" {
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = "us-east-1b"
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = true
}

# RESOURCE: ROUTE TABLES FOR THE SUBNETS
resource "aws_route_table" "rt_pub" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

# RESOURCE: ROUTE TABLES ASSOCIATION TO SUBNETS
resource "aws_route_table_association" "rt_pub_sn_pub_az1a" {
  subnet_id      = aws_subnet.sn_pub_az1a.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rt_pub_sn_pub_az1b" {
  subnet_id      = aws_subnet.sn_pub_az1b.id
  route_table_id = aws_route_table.rt_pub.id
}

# RESOURCE: SECURITY GROUP
resource "aws_security_group" "vpc_sg_pub" {
    vpc_id = aws_vpc.vpc.id
    egress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "0"
        to_port     = "0"
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# RESOURCE: EC2
data "template_file" "user_data" {
    template = "${file("./scripts/user_data.sh")}"
}

resource "aws_instance" "instance-1a" {
    ami                    = "ami-00c39f71452c08778"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_pub_az1a.id
    vpc_security_group_ids = [aws_security_group.vpc_sg_pub.id]
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"
    key_name               = "vockey"
}

resource "aws_instance" "instance-1b" {
    ami                    = "ami-00c39f71452c08778"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_pub_az1b.id
    vpc_security_group_ids = [aws_security_group.vpc_sg_pub.id]
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"
    key_name               = "vockey"
}

# RESOURCE: LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "ec2_lb_tg" {
    name     = "ec2-lb-tg"
    protocol = "HTTP"
    port     = "80"
    vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_1a" {
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    target_id        = aws_instance.instance-1a.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_1b" {
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    target_id        = aws_instance.instance-1b.id
    port             = 80
}

# RESOURCE: LOAD BALANCER
resource "aws_lb" "ec2_lb" {
    name               = "ec2-lb"
    load_balancer_type = "application"
    subnets            = [aws_subnet.sn_pub_az1a.id, aws_subnet.sn_pub_az1b.id]
    security_groups    = [aws_security_group.vpc_sg_pub.id]
}

resource "aws_lb_listener" "ec2_lb_listener" {
    protocol          = "HTTP"
    port              = "80"
    load_balancer_arn = aws_lb.ec2_lb.arn
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    }
}