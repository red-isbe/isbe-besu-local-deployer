================
CODE SNIPPETS
================
TITLE: Install NSS Tools for Certificate Management
DESCRIPTION: Provides instructions for installing the `libnss3-tools` package on Linux and `nss` on macOS. For macOS, it also includes commands to create symbolic links for `libnss3.dylib` and `libsoftokn3.dylib` within the JDK's library path, which are necessary for certain certificate operations.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
sudo apt install libnss3-tools
```

LANGUAGE: bash
CODE:
```
brew install nss
ln -s /opt/homebrew/lib/libnss3.dylib <jdk_path>/lib/libnss3.dylib
ln -s /opt/homebrew/lib/libsoftokn3.dylib <jdk_path>/lib/libsoftokn3.dylib
```

--------------------------------

TITLE: Complete script to build EvmTool and run execution tests on macOS
DESCRIPTION: This comprehensive script automates the entire setup process on macOS, including installing Java, cloning and building Besu (EvmTool), installing Ethereum/Solidity tools, cloning execution tests, setting up Python, and finally running the tests with the built EvmTool.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/evmtool/README.md#_snippet_6

LANGUAGE: zsh
CODE:
```
sdk install java 21.0.3-tem 
sdk use java 21.0.3-tem
git clone https://github.com/hyperledger/besu
cd besu
./gradlew installDist -x test
cd ..

brew install ethereum solidity
solc-select install latest
solc-select use latest
git clone https://github.com/ethereum/execution-spec-tests
cd execution-spec-tests
python3 -m venv ./venv/
source ./venv/bin/activate
pip install -e .\\[docs,lint,test\\]

fill -v tests --evm-bin ../besu/build/install/besu/bin/evmtool
```

--------------------------------

TITLE: Install Truffle Globally
DESCRIPTION: Installs the Truffle development framework globally using npm, making the `truffle` command accessible from any directory in the system. This is a foundational step for any Truffle-based smart contract development.

SOURCE: https://github.com/tasty007/besu/blob/main/acceptance-tests/tests/simple-permissioning-smart-contract/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
npm install -g truffle
```

--------------------------------

TITLE: Verify Keystore Contents
DESCRIPTION: Lists the detailed contents of a PKCS12 keystore, including certificates and key pairs, using `keytool`. This command is used to verify that certificates have been correctly imported and are present in the keystore.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_9

LANGUAGE: bash
CODE:
```
keytool -keystore $CLIENT.p12 -storepass test123 -list -v
```

--------------------------------

TITLE: Initialize NSS Database
DESCRIPTION: Sets up environment variables for the client and organization unit, creates a directory for the NSS database, creates a password file, initializes an empty NSS database using `certutil`, and creates a placeholder `secmod.db` file. This prepares the environment for managing certificates with NSS tools.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_10

LANGUAGE: bash
CODE:
```
export CLIENT=client1
export OU=partner1

mkdir nssdb
echo "test123" > nsspin.txt
certutil -N -d sql:nssdb -f nsspin.txt
touch ./nssdb/secmod.db
```

--------------------------------

TITLE: Set Client Environment Variables
DESCRIPTION: Defines the `OU` (Organization Unit) and `CLIENT` environment variables, which are used in subsequent key generation and certificate management commands. This is a preparatory step for client-specific operations.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_5

LANGUAGE: bash
CODE:
```
cd partner1client1

export OU=partner1
export CLIENT=client1
```

--------------------------------

TITLE: Install Truffle HDWallet Provider
DESCRIPTION: Installs the `truffle-hdwallet-provider` package, which is crucial for connecting Truffle to blockchain networks using mnemonic phrases or private keys. This provider enables wallet integration for deploying and interacting with contracts.

SOURCE: https://github.com/tasty007/besu/blob/main/acceptance-tests/tests/simple-permissioning-smart-contract/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
npm install truffle-hdwallet-provider
```

--------------------------------

TITLE: Define Certificate Authority Keystore Variables
DESCRIPTION: Navigates into the `ca_certs` directory and sets environment variables for the filenames of the Root, Intermediate, Partner1, and Partner2 CA keystores. These variables are used in subsequent `keytool` commands to specify keystore paths.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
cd ca_certs

export ROOT_CA_KS=root_ca.p12
export INTER_CA_KS=inter_ca.p12
export PARTNER1_CA_KS=partner1_ca.p12
export PARTNER2_CA_KS=partner2_ca.p12
```

--------------------------------

TITLE: Windows Batch Script for Java Application Startup
DESCRIPTION: This batch script is designed to start a Java application on Windows. It handles the detection of the Java Runtime Environment (JRE) or Java Development Kit (JDK) via `JAVA_HOME` or system PATH, sets up default JVM options, and constructs the command line for executing the main Java class. It includes error handling for missing Java installations and uses placeholders for dynamic configuration.

SOURCE: https://github.com/tasty007/besu/blob/main/besu/src/main/scripts/windowsStartScript.txt#_snippet_0

LANGUAGE: Batch
CODE:
```
@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  ${applicationName} startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.\

set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%${appHomeRelativePath}

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and ${optsEnvironmentVar} to pass JVM options to this script.
set DEFAULT_JVM_OPTS=${defaultJvmOpts}

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=$classpath
<% if ( mainClassName.startsWith('--module ') ) { %>set MODULE_PATH=$modulePath<% } %>

@rem Execute ${applicationName}
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %${optsEnvironmentVar}% <% if ( appNameSystemProperty ) { %>"-D${appNameSystemProperty}=%APP_BASE_NAME%"<% } %> -classpath "%CLASSPATH%" <% if ( mainClassName.startsWith('--module ') ) { %>--module-path "%MODULE_PATH%" <% } %>${mainClassName} %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable ${exitEnvironmentVar} if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%${exitEnvironmentVar}%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
```

--------------------------------

TITLE: Complete script to set up Ethereum execution tests on macOS
DESCRIPTION: This comprehensive script installs necessary dependencies (ethereum, solidity), clones the execution-spec-tests repository, sets up a Python virtual environment, and installs required Python packages.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/evmtool/README.md#_snippet_2

LANGUAGE: zsh
CODE:
```
brew install ethereum solidity
git clone https://github.com/ethereum/execution-spec-tests
cd execution-spec-tests
python3 -m venv ./venv/
source ./venv/bin/activate
pip install -e .\\[docs,lint,test\\]
```

--------------------------------

TITLE: Generate PKCS11 Configuration File for NSS
DESCRIPTION: Creates a PKCS11 configuration file (`nss.cfg`) using a heredoc. This file specifies parameters for the NSS crypto module, including its name, the directory of the NSS database, and operational modes, enabling applications to interact with the NSS database as a hardware security module (HSM).

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_12

LANGUAGE: bash
CODE:
```
cat <<EOF >./nss.cfg
name = NSScrypto-${OU}-${CLIENT}
nssSecmodDirectory = ./src/test/resources/keys/partner1client1/nssdb
nssDbMode = readOnly
nssModule = keystore
showInfo = true
EOF
```

--------------------------------

TITLE: Windows Batch Script for Java Application Startup
DESCRIPTION: This comprehensive Windows batch script is designed to start a Java application. It first checks for the presence of java.exe in the system's PATH or via the JAVA_HOME environment variable. It then constructs the classpath and module path, and executes the Java application with specified JVM options and application-specific arguments. Error handling for missing Java installations is included.

SOURCE: https://github.com/tasty007/besu/blob/main/testfuzz/src/main/scripts/windowsStartScript.txt#_snippet_0

LANGUAGE: Batchfile
CODE:
```
@rem
@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  ${applicationName} startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.\

set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%${appHomeRelativePath}

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and ${optsEnvironmentVar} to pass JVM options to this script.
set DEFAULT_JVM_OPTS=${defaultJvmOpts}

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=$classpath
<% if ( mainClassName.startsWith('--module ') ) { %>set MODULE_PATH=$modulePath<% } %>

@rem Execute ${applicationName}
"%JAVA_EXE%" -javaagent:%APP_HOME%/lib/jacocoagent.jar %DEFAULT_JVM_OPTS% %JAVA_OPTS% %${optsEnvironmentVar}% <% if ( appNameSystemProperty ) { %>"-D${appNameSystemProperty}=%APP_BASE_NAME%"<% } %> -classpath "%CLASSPATH%" <% if ( mainClassName.startsWith('--module ') ) { %>--module-path "%MODULE_PATH%" <% } %>${mainClassName} %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable ${exitEnvironmentVar} if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%${exitEnvironmentVar}%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega

```

--------------------------------

TITLE: Import CA Certificates into Truststore
DESCRIPTION: This snippet demonstrates how to import root, intermediate, and partner-specific CA certificates into a PKCS12 truststore using `keytool`. It assumes the current directory is a client-specific directory and uses environment variables for organization unit (OU).

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_4

LANGUAGE: bash
CODE:
```
cd partner2client1

export OU=partner2

keytool -import -trustcacerts -alias root_ca \
-file ../ca_certs/root_ca.pem -keystore truststore.p12 \
-storepass test123 -noprompt

keytool -import -trustcacerts -alias inter_ca \
-file ../ca_certs/inter_ca.pem -keystore truststore.p12 \
-storepass test123 -noprompt

keytool -import -trustcacerts -alias ${OU}_ca \
-file ../ca_certs/${OU}_ca.pem -keystore truststore.p12 \
-storepass test123 -noprompt
```

--------------------------------

TITLE: Import Client Keystore and CA Certificates into NSS
DESCRIPTION: Imports a client's PKCS12 keystore into the NSS database using `pk12util`. Subsequently, it imports and trusts root, intermediate, and partner-specific CA certificates within the NSS database using `certutil`. Finally, it lists the certificates in the NSS database for verification.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_11

LANGUAGE: bash
CODE:
```
pk12util -i ./$CLIENT.p12 -d sql:nssdb -k nsspin.txt -W test123
certutil -M -n "CN=root.ca.besu.com" -t CT,C,C -d sql:nssdb -f ./nsspin.txt
certutil -M -n "CN=inter.ca.besu.com" -t CT,C,C -d sql:nssdb -f ./nsspin.txt
certutil -M -n "CN=${OU}.ca.besu.com" -t CT,C,C -d sql:nssdb -f ./nsspin.txt

certutil -d sql:nssdb -f nsspin.txt -L
```

--------------------------------

TITLE: Generate Root and Intermediate Certificate Authority Keystores
DESCRIPTION: Generates self-signed keystores for the Root CA, Intermediate CA, Partner1 CA, and Partner2 CA using `keytool`. Each command creates a new key pair and certificate, specifying common name (CN), basic constraints (bc), key usage (ku), key algorithm (RSA), signature algorithm (SHA256WithRSA), validity period (36500 days), and store password.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_2

LANGUAGE: bash
CODE:
```
keytool -genkeypair -alias root_ca -dname "CN=root.ca.besu.com" -ext bc:c -keyalg RSA \
-sigalg SHA256WithRSA -validity 36500 \
-storepass test123 \
-keystore $ROOT_CA_KS

keytool -genkeypair -alias inter_ca -dname "CN=inter.ca.besu.com" \
-ext bc:c=ca:true,pathlen:1 -ext ku:c=dS,kCS,cRLs \
-keyalg RSA -sigalg SHA256WithRSA -validity 36500 \
-storepass test123 \
-keystore $INTER_CA_KS

keytool -genkeypair -alias partner1_ca -dname "CN=partner1.ca.besu.com" \
-ext bc:c=ca:true,pathlen:0 -ext ku:c=dS,kCS,cRLs \
-keyalg RSA -sigalg SHA256WithRSA -validity 36500 \
-storepass test123 \
-keystore $PARTNER1_CA_KS

keytool -genkeypair -alias partner2_ca -dname "CN=partner2.ca.besu.com" \
-ext bc:c=ca:true,pathlen:0 -ext ku:c=dS,kCS,cRLs \
-keyalg RSA -sigalg SHA256WithRSA -validity 36500 \
-storepass test123 \
-keystore $PARTNER2_CA_KS
```

--------------------------------

TITLE: Generate RSA Key Pair for Client
DESCRIPTION: Generates an RSA key pair and self-signed certificate for a client using `keytool`. Specifies the validity period, distinguished name (DN), and Subject Alternative Names (SANs). This is an alternative to EC key generation for other clients.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_7

LANGUAGE: bash
CODE:
```
keytool -genkeypair -keystore $CLIENT.p12 -storepass test123 -alias $CLIENT \
-keyalg RSA -validity 36500 \
-dname "CN=$CLIENT.$OU.besu.com, OU=$OU, O=Besu, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1
```

--------------------------------

TITLE: Besu Application Startup Script (Shell)
DESCRIPTION: This script is responsible for setting up the execution environment for the Besu application. It includes logic for resolving the application's home directory, setting default JVM options, checking for a valid Java installation, and adjusting system limits like file descriptors. It also contains OS-specific adjustments for Cygwin, MSYS, Darwin, and NonStop systems.

SOURCE: https://github.com/tasty007/besu/blob/main/testfuzz/src/main/scripts/unixStartScript.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##############################################################################
##
##  ${applicationName} start up script for UN*X
##
##############################################################################

# Attempt to set APP_HOME
# Resolve links: \$0 may be a link
PRG="\$0"
# Need this for relative symlinks.
while [ -h "\$PRG" ] ; do
    ls=`ls -ld "\$PRG"`
    link=`expr "\$ls" : '.*-> \\(.*\\)\$'`
    if expr "\$link" : '/.*' > /dev/null; then
        PRG="\$link"
    else
        PRG=`dirname "\$PRG"`"/\$link"
    fi
done
SAVED="`pwd`"
cd "`dirname "\$PRG"`/${appHomeRelativePath}" >/dev/null
APP_HOME="`pwd -P`"
cd "\$SAVED" >/dev/null

APP_NAME="${applicationName}"
APP_BASE_NAME=`basename "\$0"`

# Add default JVM options here. You can also use JAVA_OPTS and ${optsEnvironmentVar} to pass JVM options to this script.
DEFAULT_JVM_OPTS=${defaultJvmOpts}

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD="maximum"

warn () {
    echo "\$*"
}

die () {
    echo
    echo "\$*"
    echo
    exit 1
}

# OS specific support (must be 'true' or 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "`uname`" in
  CYGWIN*
    cygwin=true
    ;;
  Darwin*
    darwin=true
    ;;
  MSYS* | MINGW*
    msys=true
    ;;
  NONSTOP*
    nonstop=true
    ;;
esac

CLASSPATH=$classpath
<% if ( mainClassName.startsWith('--module ') ) { %>MODULE_PATH=$modulePath<% } %>

# Determine the Java command to use to start the JVM.
if [ -n "\$JAVA_HOME" ] ; then
    if [ -x "\$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="\$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="\$JAVA_HOME/bin/java"
    fi
    if [ ! -x "\$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: \$JAVA_HOME\n\nPlease set the JAVA_HOME variable in your environment to match the\nlocation of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.\n\nPlease set the JAVA_HOME variable in your environment to match the\nlocation of your Java installation."
fi

# Increase the maximum file descriptors if we can.
if [ "\$cygwin" = "false" -a "\$darwin" = "false" -a "\$nonstop" = "false" ] ; then
    MAX_FD_LIMIT=`ulimit -H -n`
    if [ \$? -eq 0 ] ; then
        if [ "\$MAX_FD" = "maximum" -o "\$MAX_FD" = "max" ] ; then
            MAX_FD="\$MAX_FD_LIMIT"
        fi
        ulimit -n \$MAX_FD
        if [ \$? -ne 0 ] ; then
            warn "Could not set maximum file descriptor limit: \$MAX_FD"
        fi
    else
        warn "Could not query maximum file descriptor limit: \$MAX_FD_LIMIT"
    fi
fi

# For Darwin, add options to specify how the application appears in the dock
if \$darwin; then
    GRADLE_OPTS="\$GRADLE_OPTS \"-Xdock:name=\$APP_NAME\" \"-Xdock:icon=\$APP_HOME/media/gradle.icns\""
fi
```

--------------------------------

TITLE: Generate EC Key Pair for Client
DESCRIPTION: Generates an Elliptic Curve (EC) key pair and self-signed certificate for a client using `keytool`. Specifies the `secp256r1` group, validity period, distinguished name (DN), and Subject Alternative Names (SANs). This is specifically for `partner1client1`.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_6

LANGUAGE: bash
CODE:
```
keytool -genkeypair -keystore $CLIENT.p12 -storepass test123 -alias $CLIENT \
-keyalg EC -groupname secp256r1 -validity 36500 \
-dname "CN=$CLIENT.$OU.besu.com, OU=$OU, O=Besu, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1
```

--------------------------------

TITLE: Generate CSR and Reimport Signed Certificate
DESCRIPTION: Generates a Certificate Signing Request (CSR) from the client's keystore, pipes it to `keytool` to be signed by a CA, appends the root CA certificate, and then reimports the full certificate chain back into the client's keystore. This process is crucial for obtaining a CA-signed client certificate.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_8

LANGUAGE: bash
CODE:
```
keytool -storepass test123 -keystore "$CLIENT.p12" -certreq -alias $CLIENT \
| keytool -storepass test123 -keystore "../ca_certs/${OU}_ca.p12" -gencert -validity 36500 -alias ${OU}_ca \
-ext ku:c=digitalSignature,nonRepudiation,keyEncipherment -ext eku=sA,cA -rfc > "$CLIENT.pem"

cat ../ca_certs/root_ca.pem >> $CLIENT.pem

keytool -keystore $CLIENT.p12 -importcert -alias $CLIENT \
-storepass test123 -noprompt -file ./$CLIENT.pem
```

--------------------------------

TITLE: Sign and Import Certificates for CA Hierarchy
DESCRIPTION: This sequence of `keytool` commands establishes the certificate trust chain. It involves exporting the Root CA certificate, generating Certificate Signing Requests (CSRs) for the Intermediate, Partner1, and Partner2 CAs, signing these CSRs with their respective parent CAs, and then importing the signed certificates back into their keystores. The process also includes concatenating the Root CA certificate to the signed intermediate and partner certificates to ensure a complete chain.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_3

LANGUAGE: bash
CODE:
```
keytool -storepass test123 -keystore $ROOT_CA_KS -alias root_ca -exportcert -rfc > root_ca.pem

keytool -storepass test123 -keystore $INTER_CA_KS -certreq -alias inter_ca \
| keytool -storepass test123 -keystore $ROOT_CA_KS -gencert -validity 36500 -alias root_ca \
-ext bc:c=ca:true,pathlen:1 -ext ku:c=dS,kCS,cRLs -rfc > inter_ca.pem

cat root_ca.pem >> inter_ca.pem

keytool -keystore $INTER_CA_KS -importcert -alias inter_ca \
-storepass test123 -noprompt -file ./inter_ca.pem

keytool -storepass test123 -keystore $PARTNER1_CA_KS -certreq -alias partner1_ca \
| keytool -storepass test123 -keystore $INTER_CA_KS -gencert -validity 36500 -alias inter_ca \
-ext bc:c=ca:true,pathlen:0 -ext ku:c=dS,kCS,cRLs -rfc > partner1_ca.pem

keytool -storepass test123 -keystore $PARTNER2_CA_KS -certreq -alias partner2_ca \
| keytool -storepass test123 -keystore $INTER_CA_KS -gencert -validity 36500 -alias inter_ca \
-ext bc:c=ca:true,pathlen:0 -ext ku:c=dS,kCS,cRLs -rfc > partner2_ca.pem

cat root_ca.pem >> partner1_ca.pem
cat root_ca.pem >> partner2_ca.pem

keytool -keystore $PARTNER1_CA_KS -importcert -alias partner1_ca \
-storepass test123 -noprompt -file ./partner1_ca.pem

keytool -keystore $PARTNER2_CA_KS -importcert -alias partner2_ca \
-storepass test123 -noprompt -file ./partner2_ca.pem

cd ..
```

--------------------------------

TITLE: Navigate to Smart Contract Acceptance Tests
DESCRIPTION: Changes the current working directory to the specific location of the `simple-permissioning-smart-contract` acceptance tests. This directory contains the Truffle project configuration, smart contracts, and migration scripts necessary for deployment and testing.

SOURCE: https://github.com/tasty007/besu/blob/main/acceptance-tests/tests/simple-permissioning-smart-contract/README.md#_snippet_2

LANGUAGE: bash
CODE:
```
cd acceptance-tests/simple-permissioning-smart-contract
```

--------------------------------

TITLE: Start OpenTelemetry Collector and Zipkin
DESCRIPTION: This command initiates the OpenTelemetry Collector and Zipkin service using Docker Compose, setting up the necessary infrastructure for trace collection and visualization.

SOURCE: https://github.com/tasty007/besu/blob/main/docs/tracing/README.md#_snippet_0

LANGUAGE: shell
CODE:
```
docker-compose up
```

--------------------------------

TITLE: Install Java 21 JDK using SDKMAN
DESCRIPTION: These commands use SDKMAN to install a specific version of Java (Temurin 21.0.3) and then set it as the active Java version for the current shell session.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/evmtool/README.md#_snippet_3

LANGUAGE: zsh
CODE:
```
sdk install java 21.0.3-tem 
sdk use java 21.0.3-tem
```

--------------------------------

TITLE: Generate and Verify Certificate Revocation List (CRL)
DESCRIPTION: Exports private keys and certificates from PKCS12 files to PEM format using `openssl`. It then uses `gnutls-certtool` to generate a CRL by revoking specific client certificates, appending them to a `crl.pem` file. Finally, it verifies the generated CRL using `keytool` and cleans up temporary files. This process demonstrates how to manage certificate revocation.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/p2p/src/test/resources/keys/README.md#_snippet_13

LANGUAGE: bash
CODE:
```
openssl pkcs12 -nodes -in ../ca_certs/partner1_ca.p12 -out partner1_ca_key.pem -passin pass:test123 -nocerts
openssl pkcs12 -nodes -in ../ca_certs/partner1_ca.p12 -out partner1_ca.pem -passin pass:test123 -nokeys

openssl pkcs12 -nodes -in ../ca_certs/partner2_ca.p12 -out partner2_ca_key.pem -passin pass:test123 -nocerts
openssl pkcs12 -nodes -in ../ca_certs/partner2_ca.p12 -out partner2_ca.pem -passin pass:test123 -nokeys

openssl pkcs12 -nokeys -clcerts -in ../partner1client2rvk/client2.p12 -out partner1client2.pem -passin pass:test123
openssl pkcs12 -nokeys -clcerts -in ../partner2client2rvk/client2.p12 -out partner2client2.pem -passin pass:test123

gnutls-certtool --generate-crl --load-ca-privkey ./partner1_ca_key.pem --load-ca-certificate ./partner1_ca.pem \
--load-certificate ./partner1client2.pem >> crl.pem
gnutls-certtool --generate-crl --load-ca-privkey ./partner2_ca_key.pem --load-ca-certificate ./partner2_ca.pem \
--load-certificate ./partner2client2.pem >> crl.pem

keytool -printcrl -file ./crl.pem

rm *_ca_key.pem
rm *_ca.pem
rm *client2.pem
```

--------------------------------

TITLE: Install Python packages with escaped braces for Zsh
DESCRIPTION: This command installs Python packages from the current directory in editable mode, including documentation, linting, and testing dependencies. Braces are escaped for compatibility with Zsh.

SOURCE: https://github.com/tasty007/besu/blob/main/ethereum/evmtool/README.md#_snippet_1

LANGUAGE: zsh
CODE:
```
pip install -e .\\[docs,lint,test\\]
```

--------------------------------

TITLE: Conditional Jemalloc Memory Allocator Setup
DESCRIPTION: This script block conditionally configures the `jemalloc` memory allocator. It checks for `jemalloc` availability on non-Darwin and non-MSYS systems by attempting to preload `libjemalloc.so`. If successful, it exports `LD_PRELOAD` to use `jemalloc`; otherwise, it sets `MALLOC_ARENA_MAX` to 2 as a fallback.

SOURCE: https://github.com/tasty007/besu/blob/main/testfuzz/src/main/scripts/unixStartScript.txt#_snippet_4

LANGUAGE: Shell
CODE:
```
unset BESU_USING_JEMALLOC
if [ "\$darwin" = "false" -a "\$msys" = "false" ]; then
  # check if jemalloc is available
  TEST_JEMALLOC=\$(LD_PRELOAD=libjemalloc.so sh -c true 2>&1)

  # if jemalloc is available the output is empty, otherwise the output has an error line
  if [ -z "\$TEST_JEMALLOC" ]; then
    export LD_PRELOAD=libjemalloc.so
    export BESU_USING_JEMALLOC=true
  else
    # jemalloc not available, as fallback limit malloc to 2 arenas
    export MALLOC_ARENA_MAX=2
  fi
fi
```

--------------------------------

TITLE: Start Hyperledger Besu with OpenTelemetry Tracing
DESCRIPTION: This command starts Hyperledger Besu with OpenTelemetry tracing enabled. It configures the service name, and sets up insecure exporters for metrics and spans, allowing Besu to send trace data to the OpenTelemetry Collector.

SOURCE: https://github.com/tasty007/besu/blob/main/docs/tracing/README.md#_snippet_1

LANGUAGE: shell
CODE:
```
OTEL_RESOURCE_ATTRIBUTES="service.name=besu-dev" OTEL_EXPORTER_OTLP_METRIC_INSECURE=true OTEL_EXPORTER_OTLP_SPAN_INSECURE=true ./gradlew run --args="--network=dev --rpc-http-enabled --metrics-enabled --metrics-protocol=opentelemetry"
```

--------------------------------

TITLE: Enable Private Database Migration for Hyperledger Besu v1.4
DESCRIPTION: To initiate the private transaction database migration when upgrading Hyperledger Besu to v1.4, the `--privacy-enable-database-migration` flag must be added to the Besu command line options. This flag triggers the automatic migration process upon startup, which is mandatory for nodes with existing private transactions from v1.3.5 or later. Failure to include this flag will prevent v1.4 from starting if private transactions exist.

SOURCE: https://github.com/tasty007/besu/blob/main/docs/Private-Txns-Migration.md#_snippet_0

LANGUAGE: Shell
CODE:
```
besu --privacy-enable-database-migration [other_besu_options]
```

--------------------------------

TITLE: Migrate Truffle Smart Contracts
DESCRIPTION: Deploys the smart contracts defined in the Truffle project to the configured blockchain network, typically Ganache or a Besu instance. This command compiles contracts, executes migration scripts, and records deployment information on the blockchain. The output includes compilation details, transaction hashes, contract addresses, and gas costs.

SOURCE: https://github.com/tasty007/besu/blob/main/acceptance-tests/tests/simple-permissioning-smart-contract/README.md#_snippet_3

LANGUAGE: bash
CODE:
```
truffle migrate
```

--------------------------------

TITLE: Run Truffle Smart Contract Tests
DESCRIPTION: Executes the JavaScript tests written for the smart contracts within the Truffle project. This command compiles contracts if necessary and runs all test files, providing detailed output on test results (passing/failing). The expected output includes compilation messages and a summary of test outcomes for each contract.

SOURCE: https://github.com/tasty007/besu/blob/main/acceptance-tests/tests/simple-permissioning-smart-contract/README.md#_snippet_4

LANGUAGE: bash
CODE:
```
truffle test
```

--------------------------------

TITLE: Interact with JSON-RPC API using cURL
DESCRIPTION: This cURL command demonstrates how to interact with the Hyperledger Besu JSON-RPC API. It sends a POST request to retrieve the client version, providing a simple example of API communication.

SOURCE: https://github.com/tasty007/besu/blob/main/docs/tracing/README.md#_snippet_2

LANGUAGE: shell
CODE:
```
curl -X POST --data '{\"jsonrpc\":\"2.0\",\"method\":\"web3_clientVersion\",\"params\":[],\"id\":53}' http://localhost:8545
```

--------------------------------

TITLE: Constructing and Executing the Java Command for Besu
DESCRIPTION: This section constructs the final `java` command by combining default JVM options, user-defined Java options, application-specific options (like `appNameSystemProperty`), classpath, module path, main class name, and escaped application arguments. Finally, it uses `exec` to replace the current shell process with the Java application.

SOURCE: https://github.com/tasty007/besu/blob/main/besu/src/main/scripts/unixStartScript.txt#_snippet_3

LANGUAGE: Shell
CODE:
```
APP_ARGS=`save "$@"`

# Collect all arguments for the java command, following the shell quoting and substitution rules
eval set -- $DEFAULT_JVM_OPTS $JAVA_OPTS ${optsEnvironmentVar} <% if ( appNameSystemProperty ) { %>"\"-D${appNameSystemProperty}=$APP_BASE_NAME\"" <% } %>-classpath "\"$CLASSPATH\"" <% if ( mainClassName.startsWith('--module ') ) { %>--module-path "\"$MODULE_PATH\"" <% } %>${mainClassName} "$APP_ARGS"

exec "$JAVACMD" "$@"
```

--------------------------------

TITLE: Cygwin/MSYS Path Conversion and Argument Reformatting for Java Execution
DESCRIPTION: This script block detects Cygwin or MSYS environments and converts application paths (APP_HOME, CLASSPATH, MODULE_PATH) from Unix to Windows format using `cygpath`. It also re-parses command-line arguments, converting any path-like arguments to Windows format while preserving options, to ensure compatibility with the Java command.

SOURCE: https://github.com/tasty007/besu/blob/main/besu/src/main/scripts/unixStartScript.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
if [ "$cygwin" = "true" -o "$msys" = "true" ] ;
    then
    APP_HOME=`cygpath --path --mixed "$APP_HOME"`
    CLASSPATH=`cygpath --path --mixed "$CLASSPATH"`
<% if ( mainClassName.startsWith('--module ') ) { %>    MODULE_PATH=`cygpath --path --mixed "$MODULE_PATH"`<% } %>
    JAVACMD=`cygpath --unix "$JAVACMD"`

    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=`find -L / -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
    SEP=""
    for dir in $ROOTDIRSRAW ; do
        ROOTDIRS="$ROOTDIRS$SEP$dir"
        SEP="|"
    done
    OURCYGPATTERN="(^(($ROOTDIRS)))"
    # Add a user-defined pattern to the cygpath arguments
    if [ "$GRADLE_CYGPATTERN" != "" ] ; then
        OURCYGPATTERN="$OURCYGPATTERN|($GRADLE_CYGPATTERN)"
    fi
    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    i=0
    for arg in "$@" ; do
        CHECK=`echo "$arg"|egrep -c "$OURCYGPATTERN" -`
        CHECK2=`echo "$arg"|egrep -c "^-"`                                 ### Determine if an option

        if [ $CHECK -ne 0 ] && [ $CHECK2 -eq 0 ] ; then                    ### Added a condition
            eval `echo args$i`=`cygpath --path --ignore --mixed "$arg"`
        else
            eval `echo args$i`="\"$arg\""
        fi
        i=`expr $i + 1`
    done
    case $i in
        0) set -- ;;
        1) set -- "$args0" ;;
        2) set -- "$args0" "$args1" ;;
        3) set -- "$args0" "$args1" "$args2" ;;
        4) set -- "$args0" "$args1" "$args2" "$args3" ;;
        5) set -- "$args0" "$args1" "$args2" "$args3" "$args4" ;;
        6) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" ;;
        7) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" ;;
        8) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" ;;
        9) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" "$args8" ;;
    esac
fi
```

--------------------------------

TITLE: Dynamic Construction of Java Command Arguments
DESCRIPTION: This section dynamically builds the full command-line arguments for the Java Virtual Machine (JVM) and the main application. It includes setting a Java agent (jacocoagent), incorporating default and custom JVM options, defining the classpath, conditionally adding a module path, and passing application-specific arguments, using shell `eval` for proper quoting.

SOURCE: https://github.com/tasty007/besu/blob/main/testfuzz/src/main/scripts/unixStartScript.txt#_snippet_3

LANGUAGE: Shell
CODE:
```
eval set -- -javaagent:\$APP_HOME/lib/jacocoagent.jar \$DEFAULT_JVM_OPTS \$JAVA_OPTS \$${optsEnvironmentVar} <% if ( appNameSystemProperty ) { %>"\"-D${appNameSystemProperty}=\$APP_BASE_NAME\"" <% } %>-classpath "\"\$CLASSPATH\"" <% if ( mainClassName.startsWith('--module ') ) { %>--module-path "\"\$MODULE_PATH\"" <% } %>${mainClassName} "\$APP_ARGS"
```

--------------------------------

TITLE: Cygwin/MSYS Path and Argument Conversion for Java Launch
DESCRIPTION: This script block detects Cygwin or MSYS environments and converts application paths (APP_HOME, CLASSPATH, MODULE_PATH) and command-line arguments from Unix-like to Windows format using `cygpath`. It constructs a pattern to identify paths needing conversion and applies it to arguments, ensuring compatibility for Java execution.

SOURCE: https://github.com/tasty007/besu/blob/main/testfuzz/src/main/scripts/unixStartScript.txt#_snippet_1

LANGUAGE: Shell
CODE:
```
if [ "\$cygwin" = "true" -o "\$msys" = "true" ] ; then
    APP_HOME=`cygpath --path --mixed "\$APP_HOME"`
    CLASSPATH=`cygpath --path --mixed "\$CLASSPATH"`
<% if ( mainClassName.startsWith('--module ') ) { %>    MODULE_PATH=`cygpath --path --mixed "\$MODULE_PATH"`<% } %>
    JAVACMD=`cygpath --unix "\$JAVACMD"`

    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=`find -L / -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
    SEP=""
    for dir in \$ROOTDIRSRAW ; do
        ROOTDIRS="\$ROOTDIRS\$SEP\$dir"
        SEP="|"
    done
    OURCYGPATTERN="(^(\$ROOTDIRS))"
    # Add a user-defined pattern to the cygpath arguments
    if [ "\$GRADLE_CYGPATTERN" != "" ] ; then
        OURCYGPATTERN="\$OURCYGPATTERN|(\$GRADLE_CYGPATTERN)"
    fi
    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    i=0
    for arg in "\$@" ; do
        CHECK=`echo "\$arg"|egrep -c "\$OURCYGPATTERN" -`
        CHECK2=`echo "\$arg"|egrep -c "^-"`                                 ### Determine if an option

        if [ \$CHECK -ne 0 ] && [ \$CHECK2 -eq 0 ] ; then                    ### Added a condition
            eval `echo args\$i`=`cygpath --path --ignore --mixed "\$arg"`
        else
            eval `echo args\$i`="\"\$arg\""
        fi
        i=`expr \$i + 1`
    done
    case \$i in
        0) set -- ;;
        1) set -- "\$args0" ;;
        2) set -- "\$args0" "\$args1" ;;
        3) set -- "\$args0" "\$args1" "\$args2" ;;
        4) set -- "\$args0" "\$args1" "\$args2" "\$args3" ;;
        5) set -- "\$args0" "\$args1" "\$args2" "\$args3" "\$args4" ;;
        6) set -- "\$args0" "\$args1" "\$args2" "\$args3" "\$args4" "\$args5" ;;
        7) set -- "\$args0" "\$args1" "\$args2" "\$args3" "\$args4" "\$args5" "\$args6" ;;
        8) set -- "\$args0" "\$args1" "\$args2" "\$args3" "\$args4" "\$args5" "\$args6" "\$args7" ;;
        9) set -- "\$args0" "\$args1" "\$args2" "\$args3" "\$args4" "\$args5" "\$args6" "\$args7" "\$args8" ;;
    esac
fi
```

--------------------------------

TITLE: Jemalloc Memory Allocator Configuration for Besu on Linux
DESCRIPTION: This block checks for the availability of `jemalloc` on non-Darwin/MSYS systems. If `jemalloc` is found and `BESU_USING_JEMALLOC` is not explicitly false, it sets `LD_PRELOAD` to use `libjemalloc.so`. Otherwise, it falls back to limiting `malloc` arenas to 2 for performance.

SOURCE: https://github.com/tasty007/besu/blob/main/besu/src/main/scripts/unixStartScript.txt#_snippet_2

LANGUAGE: Shell
CODE:
```
if [ "$darwin" = "false" -a "$msys" = "false" ]; then
      if [ "$BESU_USING_JEMALLOC" != "FALSE" -a "$BESU_USING_JEMALLOC" != "false" ]; then
      # check if jemalloc is available
      TEST_JEMALLOC=$(LD_PRELOAD=libjemalloc.so sh -c true 2>&1)

      # if jemalloc is available the output is empty, otherwise the output has an error line
      if [ -z "$TEST_JEMALLOC" ]; then
        export LD_PRELOAD=libjemalloc.so
      else
        # jemalloc not available, as fallback limit malloc to 2 arenas
        export MALLOC_ARENA_MAX=2
      fi
    fi
fi
```