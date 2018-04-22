1 vim minion: master: xujb01
2 million: systemctl start slat-million
  ps aux | grep minion
3 master: systemctl start salt-master
 ps aux | grep master

4 config authorized
  salt-key -a xujb02 //add host
  salt-key //check

5 salt '*' test.ping  // test ping,ture host online
  salt '*' cmd.run "hostname" //test  host's cmd
  salt 'xujb0[12]' cmd.run "hostname"
  salt '*' grains.items // check item name and value
  salt '*' grains.item uuid  //check uuid
  salt '*' grains.ls //check item name
  vim /etc/salt/grains : 
      role: nginx
      env: test 
      //customize grains,notes "role: nginx" have a space,otherwise invalid,
      //need restart salt-minion service
  salt -G role:nginx cmd.run 'hostname' //-G select option of grains to execute cmd

6 pillar
    vim /etc/salt/master
    pillar_roots:
      base:
        - /srv/pillar
	//base front have 2 space "-" front have 4 spasces
   mkdir /src/pillar
   pillar can config pillar's item, how is it 2 host config save item 
   //base:
       '*' //can solution question of above
7 
