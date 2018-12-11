#!/bin/bash
augtool --autosave 'rm /files/etc/ssh/sshd_config/UseDns yes'
augtool --autosave 'set /files/etc/ssh/sshd_config/UseDns no'
print /files/etc/ssh/sshd_config/#comment[. = "UseLogin no"]
