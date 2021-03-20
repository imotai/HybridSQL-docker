if [ -d '/opt/rh/devtoolset-7' ] ; then
    scl enable devtoolset-7 bash
fi

if [ -d '/opt/rh/sclo-git212' ] ; then
    scl enable sclo-git212 bash
fi
if [ -d '/opt/rh/python27' ] ; then
    scl enable python27 bash
fi
