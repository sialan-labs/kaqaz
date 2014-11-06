Kaqaz - Note Manager
=====

Kaqaz is a modern note manager published by Sialan Lab. The focus of Kaqaz is on a better user interface so that the user can feel a different experience with it. Kaqaz has tried to provide faster access bars and present a convenient interface for the users to have an enjoyable time while working on it. Kaqaz is a free and open source software written under GPLv3 license. 

### [Download Binary Packages](http://labs.sialan.org/projects/kaqaz)

### How to Compile
#### Install dependencies

##### Ubuntu

If you're using Qt packages from apt archive instead of [qt-project.org](http://download.qt-project.org/) releases, here's the dependencies: 

    sudo apt-get install g++ gcc qtbase5-dev libqt5sql5-sqlite libqt5multimediaquick-p5 libqt5multimedia5-plugins libqt5multimedia5 qtchooser qt5-qmake qt5-default libqt5qml5 libqt5qml-graphicaleffects qtdeclarative5-dev libqt5quick5 libqt5sensors5-dev libqt5positioning5 qtpositioning5-dev qtmultimedia5-dev

##### Fedora
on Fedora (tested on Fedora 20):

    yum install qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtquick1 qt5-qtquick1-devel kde-plasma-applicationname kde-plasma-nm qt5-qtdeclarative-devel qt5-qtdeclarative-static qt5-qtgraphicaleffects qt5-qtquickcontrols openssl-devel libappindicator-devel
    
##### Other
For other operating systems and distributions search for the corresponding packages.

#### Get source code from git repository

If you want get source from git repository you should install git on your system:

    sudo apt-get install git

After git installed, get code with this command:

    git clone https://github.com/sialan-labs/kaqaz.git

#### Start building

##### Linux Desktop

Switch to source directory and run this commands:

    mkdir build && cd build
    qmake -r .. BUILD_MODE+=superdebug BUILD_MODE+=pro PREFIX=/usr

And if you want to build kaqaz like a portable app run this command instead:

    qmake -r .. BUILD_MODE+=superdebug BUILD_MODE+=pro PREFIX=/opt/kaqaz BUILD_MODE+=opt

AND Last:

    make
    make install

##### Ubuntu Touch

Switch to source directory and run this commands:

    mkdir build && cd build
    qmake -r .. BUILD_MODE+=superdebug BUILD_MODE+=pro BUILD_MODE+=ubuntutouch
    make
    make install
    
##### Other way for all operating systems

Download QtSDK from [qt-project.org](http://download.qt-project.org/), Open kaqaz.pro with QtCreator and build it.
Note: For android you must download Android-SDK and Android NDK and for iOS download XCode.

## LICENSE 

Copyright © 2014 Sialan Labs <contact@sialan.org>  
This project is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

