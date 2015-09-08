FROM andlaz/hadoop-base
MAINTAINER andras.szerdahelyi@gmail.com

ADD https://dl.dropboxusercontent.com/u/730827/hue/releases/3.8.1/hue-3.8.1.tgz /home/hue/

RUN yum install -y ruby-2.0.0.598 \
		rubygems-2.0.14
		
RUN gem install thor

RUN yum install -y rsync \
	gcc-c++ \
	make \
	python-devel \
	krb5-devel \
	krb5-libs \
	libxml2-devel \
	libxslt-devel \
	sqlite-devel \
	openssl-devel \
	openldap-devel \
	mysql-devel \
	gmp-devel \
	cyrus-sasl-devel \
	&& cd /home/hue && tar xf hue-3.8.1.tgz && cd hue-3.8.1 \
	&& make apps \
	&& chown -R hue /home/hue/hue-3.8.1 \
	&& rm /home/hue/hue-3.8.1.tgz
	
ADD etc/hue/* /etc/hue/
ADD etc/supervisor/conf.d/hue.conf /etc/supervisor/conf.d/
ADD entrypoint.sh /root/entrypoint.sh
ADD configure.rb /root/configure.rb

ENTRYPOINT ["/root/entrypoint.sh"]
