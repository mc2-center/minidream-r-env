#!/usr/bin/env bash
# Add new student users
#
# $@ = list of student user IDs
#
# Usage:
# add_users.sh student1 student2 ...

STUDENTS="$@"

for student in $STUDENTS; do
   echo "Adding student: ${student}"
   sudo useradd -m -g rstudio-user -G student -s /bin/bash $student
   echo "${student}:csbc" | sudo chpasswd
done
