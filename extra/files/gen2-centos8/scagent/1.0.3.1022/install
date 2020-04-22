#!/bin/bash
#
# Copyright (C) Microsoft Corporation. All rights reserved.
#
# Install or remove Microsoft System Center Virtual Machine Manager Agent
# 
#
# internal function to create log entry.  Timestamps with UTC
#
function WriteLog {
   
    logfile="/var/opt/microsoft/scvmmguestagent/log/scvmm-install.log"

    if [ ! -d `dirname ${logfile}` ]
    then
      mkdir -p `dirname ${logfile}`
    fi

    echo -e `date -u '+%D %T'`" UTC\t$1\t${caller}"
    echo -e `date -u '+%D %T'`" UTC\t$1\t${caller}">>"${logfile}"
    
}

function usage {
   WriteLog "Usage:"
   WriteLog "Agent installation:"
   WriteLog "install [-d installation_directory] scvmmguestagent.x.y-z.[x86|x64].tar"
   WriteLog "Remove agent:"
   WriteLog "install -r"
   WriteLog "Upgrade agent:"
   WriteLog "install -u -v x.y-z"
   exit 1
}

function installExec {
   ERROR=$((eval ${1}) 2>&1)
   rc=$?
   
   if [ $rc != 0 ]; then
       WriteLog ${ERROR}
       WriteLog "Failed to install SCVMM Guest Agent"
       exit -1
   fi   

}

function getArch {
   arch=`uname -p`

   if [ ${arch} = "unknown" ]
   then
      arch=`uname -m`
   fi
   
   if [ `echo $arch | grep -c '^i[3-6]86$'` -eq 1 ]
   then
      archfriendly="x86"
   elif [ ${arch} = "x86_64" ]
   then
      archfriendly="x64"
   else
      WriteLog "Failed to identify architecture. Exiting."
      exit -1
   fi
}

function installAgent {

   if [ ! -n "${installdir}" ] 
   then
      installdir="/opt/microsoft"
   fi
   
   installdir="${installdir}/scvmmguestagent"

   #Untar kit
   if [ ! -d "${installdir}" ]
   then
      mkdir -p "${installdir}"
   else
      if [ -d "${installdir}" ]
      then
	 rm -fr "${installdir}/bin"
	 rm -fr "${installdir}/etc"
      fi
   fi

   WriteLog "Installing SCVMM Guest Agent to ${installdir}"
   installExec 'tar -xf "${agentkit}" -C ${installdir} --overwrite'
   
   #Create default guest agent log dir
   if [ ! -d "/var/opt/microsoft/scvmmguestagent/log" ]
   then
        mkdir -p "/var/opt/microsoft/scvmmguestagent/log"
   fi

   #Move init.d script to /etc/init.d
   sed -i".bak" 's,<SCVMMHOME>,'$installdir',g' ${installdir}/bin/${servicename}
   installExec "mv ${installdir}/bin/${servicename} /etc/init.d/"
   chmod 744 "/etc/init.d/${servicename}"


   if [ ! "${nomount}" = "true" ]
   then
        if [ -n "$(uname -v | awk '/(Debian|Ubuntu)/')" ]
        then
            sed -i".bak" 's/^# Default-Start:.*/# Default-Start:     2 3 4 5/g' /etc/init.d/${servicename}
            sed -i".bak" 's/^# Default-Stop:.*/# Default-Stop:      0 1 6/g' /etc/init.d/${servicename}
            rm -f /etc/init.d/${servicename}.bak
        fi

	   #Daemon registration
	   if [ -x /usr/sbin/update-rc.d ]
	   then
		  update-rc.d ${servicename} defaults
	   elif [ -x /usr/lib/lsb/install_initd ]
	   then
		  /usr/lib/lsb/install_initd /etc/init.d/${servicename}
	   else
		  if [ -x /sbin/chkconfig ]
		  then
		 /sbin/chkconfig --add ${servicename}
		 /sbin/chkconfig --level 3 ${servicename} on
		  else
		 WriteLog "Unable to find service control mechanism. Exiting." 
		 exit -1
		  fi
	   fi
	else
		#Start agent
		WriteLog "Starting daemon"
	        installExec '/etc/init.d/${servicename} startnomount "${mntpath}"'
	fi

   WriteLog "Successfully installed SCVMM Guest Agent"

}

function removeAgent {
   WriteLog "Removing SCVMM Guest Agent"

   if [ -e /etc/init.d/${servicename} ]
   then
      #Remove daemon
      if [ -x /usr/sbin/update-rc.d ]
      then
	 update-rc.d -f ${servicename} remove > /dev/null
      elif [ -x /usr/lib/lsb/install_initd ]
      then
	/usr/lib/lsb/remove_initd /etc/init.d/${servicename}
      else
	 if [ -x /sbin/chkconfig ]
	 then
	   /sbin/chkconfig --del ${servicename}
	 fi
      fi

      rm -f /etc/init.d/${servicename}
   fi


   #Disable waagent daemon
   WriteLog "Disabling waagent daemon"

   #SystemD
   if [ -x /bin/systemctl  -o -x /usr/bin/systemctl ]
   then 
	if [ `systemctl is-enabled walinuxagent 2>/dev/null|grep enabled|wc -l` -eq 1 ]
	then
		systemctl disable walinuxagent 
		systemctl stop walinuxagent
	fi
   fi

   if [ -x /sbin/insserv ]
   then
	/sbin/insserv -r waagent
   elif [ -x /sbin/chkconfig ]
   then
	/sbin/chkconfig waagent off
   fi

   if [ -e /etc/init/waagent.conf -o  -e /etc/init/walinuxagent.conf ]
   then
	if [ -e /etc/init/waagent.conf ];then mv /etc/init/waagent.conf /etc/init/waagent.conf.disabled;fi
	if [ -e /etc/init/walinuxagent.conf ];then mv /etc/init/walinuxagent.conf /etc/init/walinuxagent.conf.disabled;fi
   elif [ -x /usr/sbin/update-rc.d ]
   then
	/usr/sbin/update-rc.d -f waagent remove
   fi 

   if [ -d "${SCVMM_HOME}" ]
   then
      #Uninstall agent
      rm -rf "${SCVMM_HOME}"
   fi   
}

function upgradeAgent {
   
   #Check for upgrade viability
   doUpgrade=0

   currentversion=`cat ${SCVMM_HOME}/etc/version`
   WriteLog "Current version: ${currentversion}"
   
   if [ `echo $currentversion |grep -c .` -eq 1 ]
   then
      currentmajor=`echo ${currentversion}|cut -f1 -d.`
      currentminor=`echo ${currentversion}|cut -f2 -d.`
      currentpatch=`echo ${currentversion}|cut -f3 -d.`
      currentbuild=`echo ${currentversion}|cut -f4 -d.`
      newmajor=`echo ${version}|cut -f1 -d.`
      newminor=`echo ${version}|cut -f2 -d.`
      newpatch=`echo ${version}|cut -f3 -d.`
      newbuild=`echo ${version}|cut -f4 -d.`
      
      if [ ${newmajor} -gt ${currentmajor} ]
      then
	 doUpgrade=1
      elif [ ${newmajor} -eq ${currentmajor} -a ${newminor} -gt ${currentminor} ]
      then
	 doUpgrade=1
      elif [ ${newmajor} -eq ${currentmajor} -a ${newminor} -eq ${currentminor} -a ${newpatch} -gt ${currentpatch} ]
      then
	 doUpgrade=1
      elif [ ${newmajor} -eq ${currentmajor} -a ${newminor} -eq ${currentminor} -a ${newpatch} -eq ${currentpatch} -a ${newbuild} -gt ${currentbuild} ]
      then
	 doUpgrade=1
      fi
   else
      WriteLog "Unable to parse installed agent version. Exiting"
      exit -1
   fi
   
   
   if [ ${doUpgrade} -eq 1 ]
   then

      WriteLog "Agent requires upgrade"

      #Back up customizations
      configfile="${SCVMM_HOME}/etc/scvmm.conf"
      if [ -e "${configfile}" ]
      then 
	    customconf=`cat ${configfile}`
      fi
      
      WriteLog "Stopping service"
      proc=`ps -aef |grep -v grep | grep ${servicename}`
 
      if [ $? -eq 0 ]
      then
          WriteLog "Stopping service ${servicename}"
	  installExec "/etc/init.d/${servicename} stop"
      else
          WriteLog "Nothing to stop"
      fi

      #Remove  
      WriteLog "Removing agent"
      removeAgent

      #Install
      WriteLog "Starting install"
      installdir=`echo ${SCVMM_HOME} |sed  's/\/scvmmguestagent//g'`
      installAgent

      #Start daemon
      WriteLog "Starting daemon"
      installExec "/etc/init.d/${servicename} start"

      #Rewrite config file
      echo -e "${customconf}" > ${configfile}

   else
      WriteLog "Current agent version is the latest."
      exit 0
   fi

   exit 1
}

#Main

archfriendly=""
agentkit=""
installdir=""
remove=0
upgrade=0
servicename="scvmmguestagent"
whoami=`whoami`

# Check root privelege
if [ "$whoami" != "root" ]; then
    WriteLog "You must be root to install this product."
    exit 2
fi

while getopts d:v:p:ur opt
do 
   case "$opt" in
   d) installdir=${OPTARG};;
   v) version=${OPTARG};;
   r) remove=1;;
   u) upgrade=1;;
   p) mntpath=${OPTARG};;
   [?])	usage;;
   esac
done
shift $(($OPTIND - 1))

#Main
getArch

#Check for SCVMM_HOME
if [[ -z "${SCVMM_HOME}" && -f /etc/init.d/${servicename} ]]
then
	SCVMM_HOME=`cat /etc/init.d/${servicename}|grep -e '^SCVMM_HOME='|cut -f2 -d=`
fi

if [ `echo ${mntpath}|grep /|wc -l` -ge 1 ]
then
  WriteLog "Install called with mount path provided"
  nomount="true"
  agentkit=`ls $(dirname ${0})/${servicename}.*.${archfriendly}.tar|head -n 1`
else
	if [ ${upgrade} -eq 0 -a ${remove} -eq 0 ]
	then
	   if [ $# -lt 1 ]
	   then
		  usage
	   fi
	fi
fi

if [ ${remove} -eq 1 ] 
then

   removeAgent


elif [ ${upgrade} -eq 1 ]
then

   if [ ! ${version} ]
   then
      WriteLog "Upgrade specified but no supplied version. Exiting."
      usage
   fi

   agentkit="$(dirname ${0})/${servicename}.${version}.${archfriendly}.tar"

   if [ -f  "${agentkit}" ]
   then
      upgradeAgent
   else
      WriteLog "Agent tar file ${agentkit} not found. Exiting."
      exit -1
   fi    

else

   #Use specified agent kit

   if [ "${nomount}" = "true" ]
   then
     agentkit=`ls $(dirname ${0})/${servicename}.*.${archfriendly}.tar|head -n 1`
   else
	   #Check for existing SCVMM guest agent and exit if found, unless mntpath provided
	   if [ -n "${SCVMM_HOME}" ]
	   then
		  if [ -d "${SCVMM_HOME}" ]
		  then
			WriteLog "Found existing SCVMM guest agent, nothing to do."
			exit 1
		  fi
	   fi

	   agentkit="${1}"
   fi

   if [ -f "${agentkit}" ]
   then
      archtest=`tar -O -f ${agentkit} -x etc/buildarch |grep -c ${archfriendly}`
      if [ ${archtest} -eq 1 ]
      then
	    installAgent
      else
	 WriteLog "Specified agent tar file does not match machine architecture. Exiting."
	 exit -1
      fi
      
   else
      WriteLog "Agent tar file ${agentkit} not found. Exiting."
      exit -1
   fi      
 
fi
