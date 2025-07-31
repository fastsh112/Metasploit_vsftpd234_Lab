output "lab_instances" {
    value = {
        for attendee, mod in module.vsftpd234-lab :
        attendee => {
            kali_name   = module.vsftpd234-lab["${attendee}"].kali_details.name
            kali_pub_ip = module.vsftpd234-lab["${attendee}"].kali_details.pub_ip
            
            target_name   = module.vsftpd234-lab["${attendee}"].target_details.name
            target_pri_ip = module.vsftpd234-lab["${attendee}"].target_details.pri_ip
        }
    }
}