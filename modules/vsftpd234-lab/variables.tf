variable "attendee_number" {
    description = "Used to create a separate subnet for each individual attendee"
    type        = string
    default     = "24"
}

variable "vpc_id" {
    description = "ID of the lab vpc"
    type        = string
}

variable "route_table_id" {
    description = "ID of the route table"
    type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.medium"
}

variable "availability_zone" {
    description = "AWS availability zone where resources will be deployed"
    type        = string
    default     = "us-west-1a" 
}

variable "kali_ami" {
    description = "AMI of the Kali Linux VM to deploy"
    type        = string
    default     = "ami-0f36db53af1422a10"

    # Official Kali AMI: "ami-0f36db53af1422a10"
}

variable "target_ami" {
    description = "AMI of the WinSer VM to deploy"
    type        = string
    default     = "ami-043b59f1d11f8f189"

    # WinSer22 = "ami-06fe666da1b90024e"
    # WinSer16 = "ami-09896dc1e97cae396"
    # Ubuntu 22.04 = "ami-043b59f1d11f8f189"
}

variable "kali_setup_script" {
    description = "Set script to configure Kali Linux VM upon deployment"
    type        = string
    default     = <<-EOT
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    mkdir /home/kali/FAST
    echo "FAST directory created" > /home/kali/FAST/setup_log.txt
    apt update -y
    echo "apt update initiated" >> /home/kali/FAST/setup_log.txt
    apt install -y kali-tools-top10
    echo "kali-tools-top10 installation initiated" >> /home/kali/FAST/setup_log.txt

    sudo apt-get update -y
    sudo apt-get full-upgrade -y
    echo "apt-get udpate & upgrade initiated" >> /home/kali/FAST/setup_log.txt

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kali-desktop-xfce xorg xrdp xorgxrdp
    echo "xfce installation initiated" >> /home/kali/FAST/setup_log.txt

    sudo sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
    echo "Port 3390 set as SSH forwarding port" >> /home/kali/FAST/setup_log.txt

    sudo systemctl enable xrdp --now
    echo "xrdp enabled" >> /home/kali/FAST/setup_log.txt

    sudo echo kali:Metasploit20250730 | sudo chpasswd
    echo "User password changed" >> /home/kali/FAST/setup_log.txt

    ssh -N -L 3390:127.0.0.1:3390
    echo "SSH forwarding enabled" >> /home/kali/FAST/setup_log.txt
    EOT
}

variable "target_setup_script" {
    description = "Set script to configure Target VM upon deployment"
    type        = string
    default     = <<-EOT
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive

    mkdir /home/ubuntu/FAST
    echo "FAST directory created!" > /home/ubuntu/FAST/setup_log.txt

    apt update -y
    echo "apt update initiated" >> /home/ubuntu/FAST/setup_log.txt

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential 
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y libpam0g-dev 
    echo "Build and dev tools installation initiated" >> /home/ubuntu/FAST/setup_log.txt

    mkdir /home/ubuntu/vsftpd234_lab
    cd /home/ubuntu/vsftpd234_lab
    git clone https://github.com/KLee-2524/vsftpd-2.3.4-lab.git
    cd vsftpd-2.3.4-lab
    echo "GitHub repository cloned" >> /home/ubuntu/FAST/setup_log.txt

    sudo chmod +x /home/ubuntu/vsftpd234_lab/vsftpd-2.3.4-lab/vsf_findlibs.sh
    echo "findlibs file permissions changed" >> /home/ubuntu/FAST/setup_log.txt

    sudo install -v -d -m 0755 /var/ftp/empty
    sudo install -v -d -m 0755 /home/ftp
    sudo groupadd -g 47 vsftpd
    sudo groupadd -g 48 ftp
    sudo useradd -c "vsftpd User"  -d /dev/null -g vsftpd -s /bin/false -u 47 vsftpd
    sudo useradd -c anonymous_user -d /home/ftp -g ftp    -s /bin/false -u 48 ftp
    echo "Vulnerable users, groups, and directories added and configured" >> /home/ubuntu/FAST/setup_log.txt

    make
    echo "vsftpd compiled" >> /home/ubuntu/FAST/setup_log.txt

    sudo install -v -m 755 vsftpd        /usr/sbin/vsftpd
    sudo install -v -m 644 vsftpd.8      /usr/share/man/man8
    sudo install -v -m 644 vsftpd.conf.5 /usr/share/man/man5
    sudo install -v -m 644 vsftpd.conf   /etc
    echo "vsftpd installed and configured" >> /home/ubuntu/FAST/setup_log.txt

    sudo vsftpd &
    echo "vsftpd 2.3.4 service started" >> /home/ubuntu/FAST/setup_log.txt

    sudo ufw allow 21/tcp
    sudo ufw allow 6200/tcp
    sudo ufw enable -y
    echo "Firewall rules modified to allow traffic on ports 21 and 6200" >> /home/ubuntu/FAST/setup_log.txt

    echo "NEVER GONNA GIVE YOU UP" > /home/ubuntu/FAST/flag.txt
    EOT
}