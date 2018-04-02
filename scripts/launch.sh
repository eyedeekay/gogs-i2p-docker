#! /usr/bin/env sh

restore_symlinks(){
    ln -sfv /usr/share/gitea/conf /var/lib/gitea/conf
    ln -sfv /usr/share/gitea/public /var/lib/gitea/public
    ln -sfv /usr/share/gitea/templates /var/lib/gitea/templates
    ln -sfv /etc/gitea/ /var/lib/gitea/custom
}

fix_perms(){
    chown -R gitea:gitea /var/lib/gitea /var/sqlite /usr/share/gitea /etc/gitea
    chmod -R o+rw /var/lib/gitea /var/sqlite /etc/gitea
}

config_user(){
    su gitea -c 'gitea web -c /etc/gitea/conf/app.ini' & sleep 5; su gitea -c 'killall gitea'
    su gitea -c "gitea admin create-user --name $username --password $password --email adm@$username.i2p --admin -c /etc/gitea/conf/app.ini"
}

restore_symlinks
fix_perms
config_user

su gitea -c 'gitea web -c /etc/gitea/conf/app.ini'
