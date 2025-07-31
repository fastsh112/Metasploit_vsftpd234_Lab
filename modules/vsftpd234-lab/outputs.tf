output "kali_details" {
    value = {
        name = aws_instance.kali-vm.tags["Name"]
        pub_ip = aws_instance.kali-vm.public_ip
    }
    description = "Kali Linux EC2 instance name"
}

output "target_details" {
    value = {
        name = aws_instance.vsftpd234-vm.tags["Name"]
        pri_ip = aws_instance.vsftpd234-vm.private_ip
    }
    description = "Target EC2 instance details"
}

output "attendee_number" {
    value = {
        attendee_number = var.attendee_number
    }
}