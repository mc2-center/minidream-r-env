

# #ADDING IN NEW USERS
# echo "shared,1234,rstudio-user;student" > example.csv
# docker cp example.csv containerId:/example.csv
# docker-compose exec rstudio /root/util/add_users.sh /example.csv
# #Or
# docker-compose exec rstudio /root/util/add_admins.sh newAdmin
# docker-compose exec rstudio /root/util/add_students.sh newStudent

docker-compose up --build -d
docker-compose exec rstudio chmod 700 /home/ubuntu
