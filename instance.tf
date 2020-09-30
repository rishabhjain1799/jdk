provider "aws" {
  region = "ap-south-1"
  profile = "rishabh"
}

resource "aws_instance" "web" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  key_name = "lw"
  security_groups = ["sg-0c6c94c3947f8a4ab"]
  subnet_id = "subnet-1e3f5452" 

  tags = {
    Name = "rishu"
  }
}

resource "aws_ebs_volume" "v1" {
  availability_zone = "ap-south-1b"
  size              =  20
  
  tags = {
    Name = "rishuv1"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.v1.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/risha/Downloads/lw.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash",
      "sudo yum install git-lfs  -y",
      "sudo git lfs install",
      "sudo git-lfs clone https://github.com/rishabhjain1799/jdk.git  /hdfs",
      "cd  /hdfs",
      "sudo mv jdk-8u221-linux-x64.rpm  /home/ec2-user",
      "cd",
      "sudo rm -rf /hdfs",
      "sudo git-lfs clone https://github.com/rishabhjain1799/hadoop.git  /hdfs",
      "cd  /hdfs",
      "sudo mv hadoop-1.2.1-1.x86_64.rpm  /home/ec2-user",
      "cd",
      "sudo rm -rf /hdfs",
      "cd /home/ec2-user",
      "sudo rpm -ivf jdk-8u221-linux-x64.rpm",
      "sudo rpm -ivh hadoop-1.2.1-1.x86_64.rpm --force",
      "cd",
      "sudo mkdir /nn",
      "cd /etc/hadoop",
      "sudo rm -rf hdfs-site.xml core-site.xml",
      "cd",
      "sudo git clone https://github.com/Anshika-Sharma-as/hadoop01.git  /hdfs",
      "cd /hdfs",
      "sudo mv hdfs-site.xml core-site.xml /etc/hadoop",
      "sudo hadoop namenode -format -force",
      "sudo hadoop-daemon.sh start namenode"
    ]
  }
}

resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.web.public_ip}:50070"
  	}
  }