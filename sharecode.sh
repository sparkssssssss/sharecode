#!/bin/bash
#20210301


##############################更新脚本##########################################
mkdir -p /jd/config/bak/ && cp /jd/config/crontab.list /jd/config/bak/crontab.list.`date +%s`
url=http://47.100.61.159:81/submitme.sh
url1=http://47.100.61.159:81/sharecode.sh
mkdir -p /jd/diyscripts/share

cd /jd/diyscripts/share;wget -q  $url1 -O sharecode.new
flag=$?
[ $flag -gt 0 ] && echo -e "下载sharecode.sh脚本失败,请检查网络!" 
[ $flag -eq 0 ] && echo -e "下载sharecode.sh脚本成功!"  && mv sharecode.new /jd/config/sharecode.sh

cd /jd/diyscripts/share;wget -q  $url -O submitme.new
flag=$?
[ $flag -gt 0 ] && echo -e "下载群助力脚本submitme.sh失败,请检查网络!" && exit 0
[ $flag -eq 0 ] && echo -e "下载群助力脚本submitme.sh成功!"  && mv submitme.new /jd/config/submitme.sh



##############################临时任务##########################################
#sed -i '/submitme.sh/d' /jd/config/crontab.list

#cd /jd/diyscripts/share;wget -q  http://47.100.61.159:81/help_pet_run.sh -O help_pet_run.new
#flag=$?
#[ $flag -gt 0 ] && echo -e "下载群助力脚本help_pet_run.sh失败,请检查网络!" 
#[ $flag -eq 0 ] && echo -e "下载群助力脚本help_pet_run.sh 成功!"  && mv help_pet_run.new /jd/config/help_pet_run.sh

##############################随机函数##########################################
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}


##############################首次部署脚本##########################################
if [ $(grep -c -w 'submitme.sh' /jd/config/crontab.list) -eq 0 ];then
  if [ $(grep -c format_share_jd_code /jd/config/crontab.list) -gt 0 ];then
    after_min=$(rand 10 20)
    submitme_time=`date -d "+${after_min} min $(grep format_share_jd_code /jd/config/crontab.list |awk '{print $2":"$1}'|head -n 1)" +"%M %H"`
    sed -i "/hangup/a${submitme_time} * * * bash /jd/config/submitme.sh > /dev/null" /jd/config/crontab.list
    echo -e "添加群助力脚本成功,格式化脚本执行后${after_min}分钟后运行!"
  else
    cron_min=$(rand 1 20) && cron_hour=0 && submitme_crontime="${cron_min} ${cron_hour} * * *"
    sed -i "/hangup/a${submitme_crontime} bash /jd/config/submitme.sh > /dev/null" /jd/config/crontab.list
    echo -e "添加群助力脚本成功,随机执行时间为1-3点之间!"
  fi
  #[ $(grep -c -w 'submitme.sh' /jd/config/crontab.list) -eq 1 ] && bash /jd/config/submitme.sh
fi


exit 0
