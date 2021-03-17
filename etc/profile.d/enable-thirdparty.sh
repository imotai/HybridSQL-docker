[ -d /depends/thirdparty/bin ] && export PATH=/depends/thirdparty/bin:$PATH

if [ -d /depends/thirdparty/jdk ] ; then
    export JAVA_HOME=/depends/thirdparty/jdk
    export PATH=$JAVA_HOME/bin:$PATH
fi

if [ -d /depends/thirdparty/maven/bin ]; then
    export PATH=/depends/thirdparty/maven/bin:$PATH
fi
