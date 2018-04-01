#! /usr/bin/env sh

fix_perms(){
    chown -R gitea:gitea /var/lib/gitea /var/sqlite /var/tmp /usr/share/gitea
    chmod -R o+rw /var/lib/gitea /var/sqlite /var/tmp
}

config_user(){
    su gitea -c 'gitea web -c /etc/gitea/conf/app.ini' & sleep 5; su gitea -c 'killall gitea'
    su gitea -c "gitea admin create-user --name $username --password $password --email adm@$username.i2p --admin -c /etc/gitea/conf/app.ini"
}

fix_perms
config_user
su gitea -c 'gitea web -c /etc/gitea/conf/app.ini'
