# partly taken from www.buildroot.org
$(call PKG_INIT_BIN, $(shell [ "$(FREETZ_PACKAGE_PERL_VERSION)" = "" ] && echo 5.27.5 || echo $(FREETZ_PACKAGE_PERL_VERSION)))
$(PKG)_SOURCE:=perl-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_5.24.1:=765ef511b5b87a164e2531403ee16b3c
$(PKG)_SOURCE_MD5_5.24.2:=62a52f0f743fa461af449bd18d63886c
$(PKG)_SOURCE_MD5_5.24.3:=b25f1b1a0082e9e2043eb3c13bba6044
$(PKG)_SOURCE_MD5_5.26.1:=a7e5c531ee1719c53ec086656582ea86
$(PKG)_SOURCE_MD5_5.27.5:=33c922c45cffc46e447099947e0db960
$(PKG)_SOURCE_MD5:=$(PKG)_SOURCE_MD5_$($(PKG)_VERSION)
$(PKG)_SITE:=http://www.cpan.org/src/5.0
$(PKG)_SOURCES:=
$(PKG)_ADDITIONAL_CPAN_MODULES:=

$(PKG)_CROSS_VERSION:=1.1.8
$(PKG)_CROSS_DIR:=$(PERL_DIR)
$(PKG)_CROSS_SOURCE:=perl-cross-$($(PKG)_CROSS_VERSION).tar.gz
$(PKG)_CROSS_SOURCE_MD5:=2317a9a390b5a9f01b9f80e7f4533df6
$(PKG)_CROSS_SITE:=https://github.com/arsv/perl-cross/releases/download/$($(PKG)_CROSS_VERSION)
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CROSS_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CROSS

$(PKG)_JSON_VERSION:=2.94
$(PKG)_JSON_DIR:=$(PERL_DIR)/cpan/JSON
$(PKG)_JSON_SOURCE:=JSON-$($(PKG)_JSON_VERSION).tar.gz
$(PKG)_JSON_SOURCE_MD5:=b1ccf48f5cee67efe734d4c59f4ab0c0
$(PKG)_JSON_SITE:=http://search.cpan.org/CPAN/authors/id/I/IS/ISHIGAKI
$(PKG)_JSON_PATCH:=JSON_Makefile.PL
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_JSON_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += JSON

$(PKG)_ERROR_VERSION:=0.17025
$(PKG)_ERROR_DIR:=$(PERL_DIR)/cpan/Error
$(PKG)_ERROR_SOURCE:=Error-$($(PKG)_ERROR_VERSION).tar.gz
$(PKG)_ERROR_SOURCE_MD5:=1a2ee7f0dc44f9ee76661a16bbbc0c48
$(PKG)_ERROR_SITE:=http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_ERROR_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += ERROR
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Error

$(PKG)_INCLATEST_VERSION:=0.500
$(PKG)_INCLATEST_DIR:=$(PERL_DIR)/cpan/inc-latest
$(PKG)_INCLATEST_SOURCE:=inc-latest-$($(PKG)_INCLATEST_VERSION).tar.gz
$(PKG)_INCLATEST_SOURCE_MD5:=d1e0deb52bcc9f9b0f990ceb077a8ffd
$(PKG)_INCLATEST_SITE:=http://search.cpan.org/CPAN/authors/id/D/DA/DAGOLDEN
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_INCLATEST_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += INCLATEST
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += inc::latest

$(PKG)_TIMEDATE_VERSION:=2.30
$(PKG)_TIMEDATE_DIR:=$(PERL_DIR)/cpan/TimeDate
$(PKG)_TIMEDATE_SOURCE:=TimeDate-$($(PKG)_TIMEDATE_VERSION).tar.gz
$(PKG)_TIMEDATE_SOURCE_MD5:=b1d91153ac971347aee84292ed886c1c
$(PKG)_TIMEDATE_SITE:=http://cpan.metacpan.org/authors/id/G/GB/GBARR
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_TIMEDATE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += TIMEDATE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += TimeDate

ifeq ($(FREETZ_OPENSSL_VERSION_1),y)
$(PKG)_NETSSLEAY_VERSION:=1.82
$(PKG)_NETSSLEAY_DIR:=$(PERL_DIR)/cpan/Net-SSLeay
$(PKG)_NETSSLEAY_SOURCE:=Net-SSLeay-$($(PKG)_NETSSLEAY_VERSION).tar.gz
$(PKG)_NETSSLEAY_SOURCE_MD5:=2170469d929d5173bacffd0cb2d7fafa
$(PKG)_NETSSLEAY_SITE:=http://search.cpan.org/CPAN/authors/id/M/MI/MIKEM
$(PKG)_NETSSLEAY_PATCH:=Net-SSLeay_Makefile.PL
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_NETSSLEAY_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += NETSSLEAY
$(PKG)_IOSOCKETSSL_VERSION:=2.052
$(PKG)_IOSOCKETSSL_DIR:=$(PERL_DIR)/cpan/IO-Socket-SSL
$(PKG)_IOSOCKETSSL_SOURCE:=IO-Socket-SSL-$($(PKG)_IOSOCKETSSL_VERSION).tar.gz
$(PKG)_IOSOCKETSSL_SOURCE_MD5:=26c9bcdfb4ba8763ef89264f21326a48
$(PKG)_IOSOCKETSSL_SITE:=http://search.cpan.org/CPAN/authors/id/S/SU/SULLR
$(PKG)_IOSOCKETSSL_PATCH:=IO-Socket-SSL_Makefile.PL
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOSOCKETSSL_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOSOCKETSSL
endif

ifeq ($(FREETZ_PACKAGE_SQLITE),y)
$(PKG)_DBI_VERSION:=1.637
$(PKG)_DBI_DIR:=$(PERL_DIR)/cpan/DBI
$(PKG)_DBI_SOURCE:=DBI-$($(PKG)_DBI_VERSION).tar.gz
$(PKG)_DBI_SOURCE_MD5:=fdcb1739c923300de7bc5250c1c75337
$(PKG)_DBI_SITE:=http://search.cpan.org/CPAN/authors/id/T/TI/TIMB
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_DBI_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += DBI
$(PKG)_DBDSQLITE_VERSION:=1.54
$(PKG)_DBDSQLITE_DIR:=$(PERL_DIR)/cpan/DBD-SQLite
$(PKG)_DBDSQLITE_SOURCE:=DBD-SQLite-$($(PKG)_DBDSQLITE_VERSION).tar.gz
$(PKG)_DBDSQLITE_SOURCE_MD5:=8f835ddacb9a4a92a52bbe2d24d18a8e
$(PKG)_DBDSQLITE_SITE:=http://search.cpan.org/CPAN/authors/id/I/IS/ISHIGAKI
$(PKG)_DBDSQLITE_PATCH:=DBD-SQLite_Makefile.PL
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_DBDSQLITE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += DBDSQLITE
endif

$(PKG)_MODULEBUILD_VERSION:=0.4224
$(PKG)_MODULEBUILD_DIR:=$(PERL_DIR)/cpan/Module-Build
$(PKG)_MODULEBUILD_SOURCE:=Module-Build-$($(PKG)_MODULEBUILD_VERSION).tar.gz
$(PKG)_MODULEBUILD_SOURCE_MD5:=b74c2f6e84b60aad3a3defd30b6f0f4d
$(PKG)_MODULEBUILD_SITE:=http://search.cpan.org/CPAN/authors/id/L/LE/LEONT
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_MODULEBUILD_SOURCE
#$(PKG)_ADDITIONAL_CPAN_MODULES += MODULEBUILD
#$(PKG)_ADDITIONAL_CPAN_MODULES_EXTRA += Module::Build

#ifeq ($(FREETZ_PACKAGE_PERL_NETADDRESSIPLOCAL),y)
$(PKG)_NETADDRESSIPLOCAL_VERSION:=0.1.2
$(PKG)_NETADDRESSIPLOCAL_DIR:=$(PERL_DIR)/cpan/Net-Address-IP-Local
$(PKG)_NETADDRESSIPLOCAL_SOURCE:=Net-Address-IP-Local-$($(PKG)_NETADDRESSIPLOCAL_VERSION).tar.gz
$(PKG)_NETADDRESSIPLOCAL_SOURCE_MD5:=404662cd2b96cbe4a1102bc5d525f727
$(PKG)_NETADDRESSIPLOCAL_SITE:=http://search.cpan.org/CPAN/authors/id/J/JM/JMEHNLE/net-address-ip-local
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_NETADDRESSIPLOCAL_SOURCE
#$(PKG)_ADDITIONAL_CPAN_MODULES += NETADDRESSIPLOCAL
#$(PKG)_ADDITIONAL_CPAN_MODULES_EXTRA += Net::Address::IP::Local
#endif

ifeq ($(FREETZ_PACKAGE_PERL_HTMLPARSER),y)
$(PKG)_HTMLPARSER_VERSION:=3.72
$(PKG)_HTMLPARSER_DIR:=$(PERL_DIR)/cpan/HTML-Parser
$(PKG)_HTMLPARSER_SOURCE:=HTML-Parser-$($(PKG)_HTMLPARSER_VERSION).tar.gz
$(PKG)_HTMLPARSER_SOURCE_MD5:=eb7505e5f626913350df9dd4a03d54a8
$(PKG)_HTMLPARSER_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTMLPARSER_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTMLPARSER
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTML::Parser
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLSIMPLE),y)
$(PKG)_XMLSIMPLE_VERSION:=2.24
$(PKG)_XMLSIMPLE_DIR:=$(PERL_DIR)/cpan/XML-Simple
$(PKG)_XMLSIMPLE_SOURCE:=XML-Simple-$($(PKG)_XMLSIMPLE_VERSION).tar.gz
$(PKG)_XMLSIMPLE_SOURCE_MD5:=1cd2e8e3421160c42277523d5b2f4dd2
$(PKG)_XMLSIMPLE_SITE:=http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLSIMPLE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLSIMPLE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::Simple
endif

ifeq ($(FREETZ_PACKAGE_PERL_PODSIMPLE),y)
$(PKG)_PODSIMPLE_VERSION:=3.35
$(PKG)_PODSIMPLE_DIR:=$(PERL_DIR)/cpan/Pod-Simple
$(PKG)_PODSIMPLE_SOURCE:=Pod-Simple-$($(PKG)_PODSIMPLE_VERSION).tar.gz
$(PKG)_PODSIMPLE_SOURCE_MD5:=ba3ca9abc2e3c7442e93ac50d1f3cbe8
$(PKG)_PODSIMPLE_SITE:=http://search.cpan.org/CPAN/authors/id/K/KH/KHW
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_PODSIMPLE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += PODSIMPLE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Pod::Simple
endif

ifeq ($(FREETZ_PACKAGE_PERL_IOSOCKETIP),y)
$(PKG)_IOSOCKETIP_VERSION:=0.39
$(PKG)_IOSOCKETIP_DIR:=$(PERL_DIR)/cpan/IO-Socket-IP
$(PKG)_IOSOCKETIP_SOURCE:=IO-Socket-IP-$($(PKG)_IOSOCKETIP_VERSION).tar.gz
$(PKG)_IOSOCKETIP_SOURCE_MD5:=fe49e4f6638c55124b4f1fb9ee8fe134
$(PKG)_IOSOCKETIP_SITE:=http://search.cpan.org/CPAN/authors/id/P/PE/PEVANS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOSOCKETIP_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOSOCKETIP
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += IO::Socket::IP
endif

ifeq ($(FREETZ_PACKAGE_PERL_LOCALECODES),y)
$(PKG)_LOCALECODES_VERSION:=3.56
$(PKG)_LOCALECODES_DIR:=$(PERL_DIR)/cpan/Locale-Codes
$(PKG)_LOCALECODES_SOURCE:=Locale-Codes-$($(PKG)_LOCALECODES_VERSION).tar.gz
$(PKG)_LOCALECODES_SOURCE_MD5:=89049c7b79ca029e5dad49e54edb458a
$(PKG)_LOCALECODES_SITE:=http://search.cpan.org/CPAN/authors/id/S/SB/SBECK
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_LOCALECODES_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += LOCALECODES
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Locale::Codes
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLSAXBASE),y)
$(PKG)_XMLSAXBASE_VERSION:=1.09
$(PKG)_XMLSAXBASE_DIR:=$(PERL_DIR)/cpan/XML-SAX-Base
$(PKG)_XMLSAXBASE_SOURCE:=XML-SAX-Base-$($(PKG)_XMLSAXBASE_VERSION).tar.gz
$(PKG)_XMLSAXBASE_SOURCE_MD5:=ec347a14065dd7aec7d9fb181b2d7946
$(PKG)_XMLSAXBASE_SITE:=http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLSAXBASE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLSAXBASE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::SAX::Base
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLPARSER),y)
$(PKG)_XMLPARSER_VERSION:=2.36
$(PKG)_XMLPARSER_DIR:=$(PERL_DIR)/cpan/XML-Parser
$(PKG)_XMLPARSER_SOURCE:=XML-Parser-$($(PKG)_XMLPARSER_VERSION).tar.gz
$(PKG)_XMLPARSER_SOURCE_MD5:=1b868962b658bd87e1563ecd56498ded
$(PKG)_XMLPARSER_SITE:=http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLPARSER_SOURCE
#$(PKG)_ADDITIONAL_CPAN_MODULES += XMLPARSER
$(PKG)_ADDITIONAL_CPAN_MODULES_EXTRA += XML::Parser
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLSAXEXPAT),y)
$(PKG)_XMLSAXEXPAT_VERSION:=0.40
$(PKG)_XMLSAXEXPAT_DIR:=$(PERL_DIR)/cpan/XML-SAX-Expat
$(PKG)_XMLSAXEXPAT_SOURCE:=XML-SAX-Expat-$($(PKG)_XMLSAXEXPAT_VERSION).tar.gz
$(PKG)_XMLSAXEXPAT_SOURCE_MD5:=ca58d1e26c437b31c52456b4b4ae5c4a
$(PKG)_XMLSAXEXPAT_SITE:=http://search.cpan.org/CPAN/authors/id/B/BJ/BJOERN
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLSAXEXPAT_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLSAXEXPAT
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::SAX::Expat
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLNAMESPACESUPPORT),y)
$(PKG)_XMLNAMESPACESUPPORT_VERSION:=1.12
$(PKG)_XMLNAMESPACESUPPORT_DIR:=$(PERL_DIR)/cpan/XML-NamespaceSupport
$(PKG)_XMLNAMESPACESUPPORT_SOURCE:=XML-NamespaceSupport-$($(PKG)_XMLNAMESPACESUPPORT_VERSION).tar.gz
$(PKG)_XMLNAMESPACESUPPORT_SOURCE_MD5:=a8916c6d095bcf073e1108af02e78c97
$(PKG)_XMLNAMESPACESUPPORT_SITE:=http://search.cpan.org/CPAN/authors/id/P/PE/PERIGRIN
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLNAMESPACESUPPORT_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLNAMESPACESUPPORT
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::NamespaceSupport
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLSAX),y)
$(PKG)_XMLSAX_VERSION:=0.99
$(PKG)_XMLSAX_DIR:=$(PERL_DIR)/cpan/XML-SAX
$(PKG)_XMLSAX_SOURCE:=XML-SAX-$($(PKG)_XMLSAX_VERSION).tar.gz
$(PKG)_XMLSAX_SOURCE_MD5:=290f5375ae87fdebfdb5bc3854019f24
$(PKG)_XMLSAX_SITE:=http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLSAX_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLSAX
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::SAX
endif

ifeq ($(FREETZ_PACKAGE_PERL_ENCODELOCALE),y)
$(PKG)_ENCODELOCALE_VERSION:=1.05
$(PKG)_ENCODELOCALE_DIR:=$(PERL_DIR)/cpan/Encode-Locale
$(PKG)_ENCODELOCALE_SOURCE:=Encode-Locale-$($(PKG)_ENCODELOCALE_VERSION).tar.gz
$(PKG)_ENCODELOCALE_SOURCE_MD5:=fcfdb8e4ee34bcf62aed429b4a23db27
$(PKG)_ENCODELOCALE_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_ENCODELOCALE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += ENCODELOCALE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Encode::Locale
endif

ifeq ($(FREETZ_PACKAGE_PERL_SCALARLISTUTILS),y)
$(PKG)_SCALARLISTUTILS_VERSION:=1.50
$(PKG)_SCALARLISTUTILS_DIR:=$(PERL_DIR)/cpan/Scalar-List-Utils
$(PKG)_SCALARLISTUTILS_SOURCE:=Scalar-List-Utils-$($(PKG)_SCALARLISTUTILS_VERSION).tar.gz
$(PKG)_SCALARLISTUTILS_SOURCE_MD5:=136313884d1afa2fb6840695a1034b2c
$(PKG)_SCALARLISTUTILS_SITE:=http://search.cpan.org/CPAN/authors/id/P/PE/PEVANS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_SCALARLISTUTILS_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += SCALARLISTUTILS
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Scalar::List::Utils
endif

ifeq ($(FREETZ_PACKAGE_PERL_DATAUUID),y)
$(PKG)_DATAUUID_VERSION:=1.221
$(PKG)_DATAUUID_DIR:=$(PERL_DIR)/cpan/Data-UUID
$(PKG)_DATAUUID_SOURCE:=Data-UUID-$($(PKG)_DATAUUID_VERSION).tar.gz
$(PKG)_DATAUUID_SOURCE_MD5:=7619929e8fe205a7fb83bc1c29ecbf99
$(PKG)_DATAUUID_SITE:=http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_DATAUUID_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += DATAUUID
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Data::UUID
endif

ifeq ($(FREETZ_PACKAGE_PERL_LIBWWWPERL),y)
$(PKG)_LIBWWWPERL_VERSION:=6.33
$(PKG)_LIBWWWPERL_DIR:=$(PERL_DIR)/cpan/libwww-perl
$(PKG)_LIBWWWPERL_SOURCE:=libwww-perl-$($(PKG)_LIBWWWPERL_VERSION).tar.gz
$(PKG)_LIBWWWPERL_SOURCE_MD5:=2e15c1c789ac9036c99d094e47e3da23
$(PKG)_LIBWWWPERL_SITE:=http://search.cpan.org/CPAN/authors/id/O/OA/OALDERS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_LIBWWWPERL_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += LIBWWWPERL
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += libwww-perl
endif

ifeq ($(FREETZ_PACKAGE_PERL_IOHTML),y)
$(PKG)_IOHTML_VERSION:=1.001
$(PKG)_IOHTML_DIR:=$(PERL_DIR)/cpan/IO-HTML
$(PKG)_IOHTML_SOURCE:=IO-HTML-$($(PKG)_IOHTML_VERSION).tar.gz
$(PKG)_IOHTML_SOURCE_MD5:=3f8958718844dc96b9f6946f21d70d22
$(PKG)_IOHTML_SITE:=http://search.cpan.org/CPAN/authors/id/C/CJ/CJM
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOHTML_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOHTML
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += IO::HTML
endif

ifeq ($(FREETZ_PACKAGE_PERL_HTTPNEGOTIATE),y)
$(PKG)_HTTPNEGOTIATE_VERSION:=6.01
$(PKG)_HTTPNEGOTIATE_DIR:=$(PERL_DIR)/cpan/HTTP-Negotiate
$(PKG)_HTTPNEGOTIATE_SOURCE:=HTTP-Negotiate-$($(PKG)_HTTPNEGOTIATE_VERSION).tar.gz
$(PKG)_HTTPNEGOTIATE_SOURCE_MD5:=1236195250e264d7436e7bb02031671b
$(PKG)_HTTPNEGOTIATE_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTTPNEGOTIATE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTTPNEGOTIATE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTTP::Negotiate
endif

ifeq ($(FREETZ_PACKAGE_PERL_NETHTTP),y)
$(PKG)_NETHTTP_VERSION:=6.17
$(PKG)_NETHTTP_DIR:=$(PERL_DIR)/cpan/Net-HTTP
$(PKG)_NETHTTP_SOURCE:=Net-HTTP-$($(PKG)_NETHTTP_VERSION).tar.gz
$(PKG)_NETHTTP_SOURCE_MD5:=068fa02fd3c8a5b63316025b5a24844c
$(PKG)_NETHTTP_SITE:=http://search.cpan.org/CPAN/authors/id/O/OA/OALDERS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_NETHTTP_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += NETHTTP
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Net::HTTP
endif

ifeq ($(FREETZ_PACKAGE_PERL_HTTPCOOKIES),y)
$(PKG)_HTTPCOOKIES_VERSION:=6.04
$(PKG)_HTTPCOOKIES_DIR:=$(PERL_DIR)/cpan/HTTP-Cookies
$(PKG)_HTTPCOOKIES_SOURCE:=HTTP-Cookies-$($(PKG)_HTTPCOOKIES_VERSION).tar.gz
$(PKG)_HTTPCOOKIES_SOURCE_MD5:=7bf1e277bd5c886bc18d21eb8423b65f
$(PKG)_HTTPCOOKIES_SITE:=http://search.cpan.org/CPAN/authors/id/O/OA/OALDERS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTTPCOOKIES_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTTPCOOKIES
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTTP::Cookies
endif

ifeq ($(FREETZ_PACKAGE_PERL_MAILDKIM),y)
$(PKG)_MAILDKIM_VERSION:=0.57
$(PKG)_MAILDKIM_DIR:=$(PERL_DIR)/cpan/Mail-DKIM
#https://cpan.metacpan.org/authors/id/M/MB/MBRADSHAW/Mail-DKIM-0.57.tar.gz
$(PKG)_MAILDKIM_SOURCE:=Mail-DKIM-$($(PKG)_MAILDKIM_VERSION).tar.gz
$(PKG)_MAILDKIM_SOURCE_MD5:=a27333a8f3295c6a15e351cd3f725d92 
$(PKG)_MAILDKIM_SITE:=http://search.cpan.org/CPAN/authors/id/M/MB/MBRADSHAW
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_MAILDKIM_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += MAILDKIM
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Mail::DKIM
endif

ifeq ($(FREETZ_PACKAGE_PERL_OPENSSLRSA),y)
$(PKG)_OPENSSLRSA_VERSION:=0.31
$(PKG)_OPENSSLRSA_DIR:=$(PERL_DIR)/cpan/Crypt-OpenSSL-RSA
$(PKG)_OPENSSLRSA_SOURCE:=Crypt-OpenSSL-RSA-$($(PKG)_OPENSSLRSA_VERSION).tar.gz
$(PKG)_OPENSSLRSA_SOURCE_MD5:=d33681e19d2094df7c26bc7a4509265e
$(PKG)_OPENSSLRSA_SITE:=https://cpan.metacpan.org/authors/id/T/TO/TODDR/
$(PKG)_OPENSSLRSA_PATCH:=14-Crypt-OpenSSL-RSA_Makefile.PL
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_OPENSSLRSA_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += OPENSSLRSA
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Crypt::OpenSSL::RSA
endif

ifeq ($(FREETZ_PACKAGE_PERL_CRYPTOPENSSLGUESS),y)
$(PKG)_CRYPTOPENSSLGUESS_VERSION:=0.11
$(PKG)_CRYPTOPENSSLGUESS_DIR:=$(PERL_DIR)/cpan/Crypt-OpenSSL-Guess
$(PKG)_CRYPTOPENSSLGUESS_SOURCE:=Crypt-OpenSSL-Guess-$($(PKG)_CRYPTOPENSSLGUESS_VERSION).tar.gz
$(PKG)_CRYPTOPENSSLGUESS_SOURCE_MD5:=e768fe2c07826b0ac9ea604c79f93032
$(PKG)_CRYPTOPENSSLGUESS_SITE:=https://cpan.metacpan.org/authors/id/A/AK/AKIYM/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CRYPTOPENSSLGUESS_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CRYPTOPENSSLGUESS
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Crypt::OpenSSL::Guess
endif

ifeq ($(FREETZ_PACKAGE_PERL_DIGESTSHA),y)
$(PKG)_DIGESTSHA_VERSION:=6.02
$(PKG)_DIGESTSHA_DIR:=$(PERL_DIR)/cpan/Digest-SHA
$(PKG)_DIGESTSHA_SOURCE:=Digest-SHA-$($(PKG)_DIGESTSHA_VERSION).tar.gz
$(PKG)_DIGESTSHA_SOURCE_MD5:=e22f92fa4e2d7ec9b1168538b307d31c
$(PKG)_DIGESTSHA_SITE:=https://cpan.metacpan.org/authors/id/M/MS/MSHELOR/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_DIGESTSHA_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += DIGESTSHA
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Digest::SHA
endif

ifeq ($(FREETZ_PACKAGE_PERL_MAILADDRESS),y)
$(PKG)_MAILADDRESS_VERSION:=2.21
$(PKG)_MAILADDRESS_DIR:=$(PERL_DIR)/cpan/MailTools
$(PKG)_MAILADDRESS_SOURCE:=MailTools-$($(PKG)_MAILADDRESS_VERSION).tar.gz
$(PKG)_MAILADDRESS_SOURCE_MD5:=69ee516d40011e7e92b77c6f06c0dc01
$(PKG)_MAILADDRESS_SITE:=https://cpan.metacpan.org/authors/id/M/MA/MARKOV/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_MAILADDRESS_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += MAILADDRESS
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Mail::Address
endif

ifeq ($(FREETZ_PACKAGE_PERL_MIMEBASE64),y)
$(PKG)_MIMEBASE64_VERSION:=3.15
$(PKG)_MIMEBASE64_DIR:=$(PERL_DIR)/cpan/MIME-Base64
$(PKG)_MIMEBASE64_SOURCE:=MIME-Base64-$($(PKG)_MIMEBASE64_VERSION).tar.gz
$(PKG)_MIMEBASE64_SOURCE_MD5:=ef958dc2bf96be5f759391c6ac1debd4
$(PKG)_MIMEBASE64_SITE:=https://cpan.metacpan.org/authors/id/G/GA/GAAS/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_MIMEBASE64_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += MIMEBASE64
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Mail::Address
endif


ifeq ($(FREETZ_PACKAGE_PERL_NETDNS),y)
$(PKG)_NETDNS_VERSION:=1.21
$(PKG)_NETDNS_DIR:=$(PERL_DIR)/cpan/Net-DNS
$(PKG)_NETDNS_SOURCE:=Net-DNS-$($(PKG)_NETDNS_VERSION).tar.gz
$(PKG)_NETDNS_SOURCE_MD5:=91e8593eb6eed41995e6edc567fb6fec
$(PKG)_NETDNS_SITE:=https://cpan.metacpan.org/authors/id/N/NL/NLNETLABS/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_NETDNS_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += NETDNS
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Net::DNS
endif


ifeq ($(FREETZ_PACKAGE_PERL_CRYPTRIJNDAEL),y)
$(PKG)_CRYPTRIJNDAEL_VERSION:=1.13
$(PKG)_CRYPTRIJNDAEL_DIR:=$(PERL_DIR)/cpan/Crypt-Rijndael
$(PKG)_CRYPTRIJNDAEL_SOURCE:=Crypt-Rijndael-$($(PKG)_CRYPTRIJNDAEL_VERSION).tar.gz
$(PKG)_CRYPTRIJNDAEL_SOURCE_MD5:=2af117c9ab4052cec05cf6737c5f3f45
$(PKG)_CRYPTRIJNDAEL_SITE:=http://search.cpan.org/CPAN/authors/id/L/LE/LEONT
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CRYPTRIJNDAEL_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CRYPTRIJNDAEL
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Crypt::Rijndael
endif

ifeq ($(FREETZ_PACKAGE_PERL_NETTELNET),y)
$(PKG)_NETTELNET_VERSION:=3.04
$(PKG)_NETTELNET_DIR:=$(PERL_DIR)/cpan/Net-Telnet
$(PKG)_NETTELNET_SOURCE:=Net-Telnet-$($(PKG)_NETTELNET_VERSION).tar.gz
$(PKG)_NETTELNET_SOURCE_MD5:=d2514080116c1b0fa5f96295c84538e3
$(PKG)_NETTELNET_SITE:=http://search.cpan.org/CPAN/authors/id/J/JR/JROGERS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_NETTELNET_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += NETTELNET
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Net::HTTP
endif

ifeq ($(FREETZ_PACKAGE_PERL_HTTPMESSAGE),y)
$(PKG)_HTTPMESSAGE_VERSION:=6.15
$(PKG)_HTTPMESSAGE_DIR:=$(PERL_DIR)/cpan/HTTP-Message
$(PKG)_HTTPMESSAGE_SOURCE:=HTTP-Message-$($(PKG)_HTTPMESSAGE_VERSION).tar.gz
$(PKG)_HTTPMESSAGE_SOURCE_MD5:=4be17a521f1c864be3330470222d93d0
$(PKG)_HTTPMESSAGE_SITE:=http://search.cpan.org/CPAN/authors/id/O/OA/OALDERS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTTPMESSAGE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTTPMESSAGE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTTP::Message
endif

ifeq ($(FREETZ_PACKAGE_PERL_HTTPDATE),y)
$(PKG)_HTTPDATE_VERSION:=6.02
$(PKG)_HTTPDATE_DIR:=$(PERL_DIR)/cpan/HTTP-Date
$(PKG)_HTTPDATE_SOURCE:=HTTP-Date-$($(PKG)_HTTPDATE_VERSION).tar.gz
$(PKG)_HTTPDATE_SOURCE_MD5:=52b7a0d5982d61be1edb217751d7daba
$(PKG)_HTTPDATE_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTTPDATE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTTPDATE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTTP::Date
endif

ifeq ($(FREETZ_PACKAGE_PERL_XMLPARSERLITE),y)
$(PKG)_XMLPARSERLITE_VERSION:=0.721
$(PKG)_XMLPARSERLITE_DIR:=$(PERL_DIR)/cpan/XML-Parser-Lite
$(PKG)_XMLPARSERLITE_SOURCE:=XML-Parser-Lite-$($(PKG)_XMLPARSERLITE_VERSION).tar.gz
$(PKG)_XMLPARSERLITE_SOURCE_MD5:=ad8a87b9bf413aa540c7cb724d650808
$(PKG)_XMLPARSERLITE_SITE:=http://search.cpan.org/CPAN/authors/id/P/PH/PHRED
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_XMLPARSERLITE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += XMLPARSERLITE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += XML::Parser::Lite
endif

ifeq ($(FREETZ_PACKAGE_PERL_CLASSINSPECTOR),y)
$(PKG)_CLASSINSPECTOR_VERSION:=1.32
$(PKG)_CLASSINSPECTOR_DIR:=$(PERL_DIR)/cpan/Class-Inspector
$(PKG)_CLASSINSPECTOR_SOURCE:=Class-Inspector-$($(PKG)_CLASSINSPECTOR_VERSION).tar.gz
$(PKG)_CLASSINSPECTOR_SOURCE_MD5:=db471d6ecf47fa054726553319b7c34f
$(PKG)_CLASSINSPECTOR_SITE:=http://search.cpan.org/CPAN/authors/id/P/PL/PLICEASE
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CLASSINSPECTOR_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CLASSINSPECTOR
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Class::Inspector
endif

ifeq ($(FREETZ_PACKAGE_PERL_SOAPLITE),y)
$(PKG)_SOAPLITE_VERSION:=1.26
$(PKG)_SOAPLITE_DIR:=$(PERL_DIR)/cpan/SOAP-Lite
$(PKG)_SOAPLITE_SOURCE:=SOAP-Lite-$($(PKG)_SOAPLITE_VERSION).tar.gz
$(PKG)_SOAPLITE_SOURCE_MD5:=1c53fe1b6d986599b1277462062ae303
$(PKG)_SOAPLITE_SITE:=http://search.cpan.org/CPAN/authors/id/P/PH/PHRED
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_SOAPLITE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += SOAPLITE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += SOAP::Lite
endif

ifeq ($(FREETZ_PACKAGE_PERL_LWPMEDIATYPES),y)
$(PKG)_LWPMEDIATYPES_VERSION:=6.02
$(PKG)_LWPMEDIATYPES_DIR:=$(PERL_DIR)/cpan/LWP-MediaTypes
$(PKG)_LWPMEDIATYPES_SOURCE:=LWP-MediaTypes-$($(PKG)_LWPMEDIATYPES_VERSION).tar.gz
$(PKG)_LWPMEDIATYPES_SOURCE_MD5:=8c5f25fb64b974d22aff424476ba13c9
$(PKG)_LWPMEDIATYPES_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_LWPMEDIATYPES_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += LWPMEDIATYPES
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += LWP::MediaTypes
endif

ifeq ($(FREETZ_PACKAGE_PERL_HTTPDAEMON),y)
$(PKG)_HTTPDAEMON_VERSION:=6.01
$(PKG)_HTTPDAEMON_DIR:=$(PERL_DIR)/cpan/HTTP-Daemon
$(PKG)_HTTPDAEMON_SOURCE:=HTTP-Daemon-$($(PKG)_HTTPDAEMON_VERSION).tar.gz
$(PKG)_HTTPDAEMON_SOURCE_MD5:=ed0ae02d25d7f1e89456d4d69732adc2
$(PKG)_HTTPDAEMON_SITE:=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_HTTPDAEMON_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += HTTPDAEMON
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += HTTP::Daemon
endif

ifeq ($(FREETZ_PACKAGE_PERL_TRYTINY),y)
$(PKG)_TRYTINY_VERSION:=0.30
$(PKG)_TRYTINY_DIR:=$(PERL_DIR)/cpan/Try-Tiny
$(PKG)_TRYTINY_SOURCE:=Try-Tiny-$($(PKG)_TRYTINY_VERSION).tar.gz
$(PKG)_TRYTINY_SOURCE_MD5:=eb362c3cb32c42f9f28de9ddb7f2ead6
$(PKG)_TRYTINY_SITE:=http://search.cpan.org/CPAN/authors/id/E/ET/ETHER
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_TRYTINY_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += TRYTINY
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Try::Tiny
endif

ifeq ($(FREETZ_PACKAGE_PERL_IOINTERFACE),y)
$(PKG)_IOINTERFACE_VERSION:=1.09
$(PKG)_IOINTERFACE_DIR:=$(PERL_DIR)/cpan/IO-Interface
$(PKG)_IOINTERFACE_SOURCE:=IO-Interface-$($(PKG)_IOINTERFACE_VERSION).tar.gz
$(PKG)_IOINTERFACE_SOURCE_MD5:=806f97aff5a7361b6f54cd494f4cc9fd
$(PKG)_IOINTERFACE_SITE:=http://search.cpan.org/CPAN/authors/id/L/LD/LDS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOINTERFACE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOINTERFACE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += IO::Interface
endif

ifeq ($(FREETZ_PACKAGE_PERL_IOSOCKETINET6),y)
$(PKG)_IOSOCKETINET6_VERSION:=2.72
$(PKG)_IOSOCKETINET6_DIR:=$(PERL_DIR)/cpan/IO-Socket-INET6
$(PKG)_IOSOCKETINET6_SOURCE:=IO-Socket-INET6-$($(PKG)_IOSOCKETINET6_VERSION).tar.gz
$(PKG)_IOSOCKETINET6_SOURCE_MD5:=510ddc1bd75a8340ca7226123fb545c1
$(PKG)_IOSOCKETINET6_SITE:=http://search.cpan.org/CPAN/authors/id/S/SH/SHLOMIF
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOSOCKETINET6_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOSOCKETINET6
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += IO::Socket::INET6
endif

ifeq ($(FREETZ_PACKAGE_PERL_IOSOCKETINET),y)
$(PKG)_IOSOCKETINET_VERSION:=1.39
$(PKG)_IOSOCKETINET_DIR:=$(PERL_DIR)/cpan/IO
$(PKG)_IOSOCKETINET_SOURCE:=IO-$($(PKG)_IOSOCKETINET_VERSION).tar.gz
$(PKG)_IOSOCKETINET_SOURCE_MD5:=0d16fc98242188e4d5735a7a98125880
$(PKG)_IOSOCKETINET_SITE:=https://cpan.metacpan.org/authors/id/T/TO/TODDR/
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_IOSOCKETINET_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += IOSOCKETINET
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += IO::Socket::INET
endif


ifeq ($(FREETZ_PACKAGE_PERL_URIESCAPE),y)
$(PKG)_URIESCAPE_VERSION:=1.72
$(PKG)_URIESCAPE_DIR:=$(PERL_DIR)/cpan/URI
$(PKG)_URIESCAPE_SOURCE:=URI-$($(PKG)_URIESCAPE_VERSION).tar.gz
$(PKG)_URIESCAPE_SOURCE_MD5:=cd56d81ed429efaa97e7f3ff08851b48
$(PKG)_URIESCAPE_SITE:=http://search.cpan.org/CPAN/authors/id/E/ET/ETHER
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_URIESCAPE_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += URIESCAPE
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += URI::Escape
endif

ifeq ($(FREETZ_PACKAGE_PERL_CRYPTCBC),y)
$(PKG)_CRYPTCBC_VERSION:=2.33
$(PKG)_CRYPTCBC_DIR:=$(PERL_DIR)/cpan/Crypt-CBC
$(PKG)_CRYPTCBC_SOURCE:=Crypt-CBC-$($(PKG)_CRYPTCBC_VERSION).tar.gz
$(PKG)_CRYPTCBC_SOURCE_MD5:=3db5117d60df67e3b400fe367e716be0
$(PKG)_CRYPTCBC_SITE:=https://cpan.metacpan.org/authors/id/L/LD/LDS
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CRYPTCBC_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CRYPTCBC
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Crypt::CBC

$(PKG)_CRYPTOPENSSLAES_VERSION:=0.02
$(PKG)_CRYPTOPENSSLAES_DIR:=$(PERL_DIR)/cpan/Crypt-OpenSSL-AES
$(PKG)_CRYPTOPENSSLAES_SOURCE:=Crypt-OpenSSL-AES-$($(PKG)_CRYPTOPENSSLAES_VERSION).tar.gz
$(PKG)_CRYPTOPENSSLAES_SOURCE_MD5:=269db65cbf580c3174471a2cbc9a9d95
$(PKG)_CRYPTOPENSSLAES_SITE:=https://cpan.metacpan.org/authors/id/T/TT/TTAR
$(PKG)_SOURCES += $(DL_DIR)/$(PKG)_CRYPTOPENSSLAES_SOURCE
$(PKG)_ADDITIONAL_CPAN_MODULES += CRYPTOPENSSLAES
$(PKG)_ADDITIONAL_CPAN_MODULES_STATIC += Crypt::OpenSSL::AES
endif

ifeq ($(FREETZ_OPENSSL_VERSION_1),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_1
endif

ifeq ($(FREETZ_PACKAGE_SQLITE),y)
$(PKG)_DEPENDS_ON += sqlite
# following comand should be ecexute by build system automatically, but it does not ,therefore call it explicitely
$(PKG)_CONFIGURE_PRE_CMDS += cat $(PERL_DBI_DIR)/Driver.xst | $(SED) 's/~DRIVER~/SQLite/g' > $(PERL_DBDSQLITE_DIR)/SQLite.xsi
endif


$(PKG)_PREFIX := $(if $(FREETZ_PACKAGE_PERL_PREFIX),$(strip $(FREETZ_PACKAGE_PERL_PREFIX)),/usr)
$(PKG)_BINARY:=$($(PKG)_DIR)/perl
ifeq ($(EXTERNAL_FREETZ_PACKAGE_PERL),y)
$(PKG)_TESTPACK:=$($(PKG)_DIR)/TESTPACK.tar.gz
endif
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PERL_PREFIX)/bin/perl
$(PKG)_TARGET_MODULES:=$($(PKG)_TARGET_DIR)/.modules_installed
$(PKG)_TARGET_MODULES_DIR:=$($(PKG)_DEST_DIR)$(PERL_PREFIX)/lib/perl5/$($(PKG)_VERSION)
$(PKG)_TARGET_MODS:=$(subst ",,$(FREETZ_PACKAGE_PERL_MODULES))

$(PKG)_PATCH_PRE_CMDS += chmod -R u+w .;
$(PKG)_PATCH_POST_CMDS += $(SED) -r -i -e 's|/5([.][0-9]{2}){1,2}|/$($(PKG)_VERSION)|g' uconfig.sh;
$(PKG)_PATCH_POST_CMDS += $(SED) -r -i -e 's|/usr/local|$($(PKG)_PREFIX)|g'                         uconfig.sh;

$(PKG_SOURCE_DOWNLOAD_NOP)
$(PKG_UNPACKED)
$(PKG_CONFIGURED)

$(PKG)_EXTRA_CFLAGS := -fno-stack-protector -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS := -Wl,--gc-sections -Wl,-rpath=$(PERL_PREFIX)/lib/perl5/$(PERL_VERSION)/mips-linux/CORE
$(PKG)_CONFIGURE_OPTIONS = -Duseshrplib -Dbyteorder='87654321' 
$(PKG)_CONFIGURE_OPTIONS += -Dextras="IO LWP Sys::Hostname Net::DNS Mail:SPF::Query Sys::Hostname::Long $(FREETZ_PACKAGE_PERL_ADDITIONAL_EXTRA_MODULES)"
$(PKG)_CONFIGURE_OPTIONS += -Accflags="$(PERL_EXTRA_CFLAGS) $(PERL_EXTRA_LDFLAGS)"

$(pkg)-download:  $(DL_DIR)/$($(PKG)_SOURCE) $($(PKG)_SOURCES)
$($(PKG)_SOURCES):
	$(foreach mod,$(subst $(DL_DIR)/PERL_,,$(subst _SOURCE,,$@)),$(DL_TOOL) $(DL_DIR) $(PERL_$(mod)_SOURCE) $(PERL_$(mod)_SITE) $(PERL_$(mod)_SOURCE_MD5))

$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR) $($(PKG)_SOURCES)
	$(DL_TOOL) $(DL_DIR) $(PERL_SOURCE) $(PERL_SITE) $(PERL_MD5)

$($(PKG)_DIR)/configure: $($(PKG)_DIR)/.unpacked
	$(foreach mod,$(PERL_ADDITIONAL_CPAN_MODULES),mkdir -p $(PERL_$(mod)_DIR); $(call UNPACK_TARBALL,$(DL_DIR)/$(PERL_$(mod)_SOURCE),$(PERL_$(mod)_DIR),1);)
	cd $(PWD); \
	$(foreach mod,$(PERL_ADDITIONAL_CPAN_MODULES),[ -n "$(PERL_$(mod)_PATCH)" -a -f $(PERL_DIR)/$(PERL_$(mod)_PATCH) ] && mv -f $(PERL_DIR)/$(PERL_$(mod)_PATCH) $(PERL_$(mod)_DIR)/Makefile.PL ||:;)
	cd $(PWD); \
	$(PERL_CONFIGURE_PRE_CMDS)
	touch $@

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/configure
	cd $(PERL_DIR) && PATH=$(TARGET_PATH) ./configure --target=$(GNU_TARGET_NAME) --target-tools-prefix=$(REAL_GNU_TARGET_NAME)- --prefix=$(PERL_PREFIX) $(PERL_CONFIGURE_OPTIONS) && \
	cd $(PWD) && touch $@

$($(PKG)_DIR)/miniperl_top: $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(PERL_DIR) -f Makefile utilities \
		CC="$(TARGET_CC)" OPTIMIZE="$(TARGET_CFLAGS)"
	touch $@

$($(PKG)_DIR)/lib/lib.pm: $($(PKG)_DIR)/miniperl_top
	cd $(PERL_DIR)/dist/lib; "../../miniperl_top" "-I../../lib" "-I../../lib" lib_pm.PL lib.pm; cp lib.pm ../../lib/lib.pm
	
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured $($(PKG)_DIR)/lib/lib.pm
	$(SUBMAKE1) -C $(PERL_DIR) -f Makefile \
		CC="$(TARGET_CC)" OPTIMIZE="$(TARGET_CFLAGS)" && \
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	 $(SUBMAKE1) -C $(PERL_DIR) -f Makefile \
	        DESTDIR="$(PWD)/$(PERL_DEST_DIR)" install.perl && \
	 cd $(PERL_DEST_DIR)/$(PERL_PREFIX)/bin; rm perl; ln -s perl$(PERL_VERSION) perl && \
	 touch perl$(PERL_VERSION)

$($(PKG)_TESTPACK) .dummy_$(pkg): $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_MODULES)
	-$(SUBMAKE1) -i -C $(PERL_DIR) -f Makefile testpack;
	cp $(PERL_TESTPACK) $(PERL_TARGET_MODULES_DIR)/.

$($(PKG)_TARGET_MODULES): $($(PKG)_DIR)/.unpacked
	mkdir -p $(PERL_TARGET_MODULES_DIR)
	( \
		for i in $(patsubst %,$(PERL_TARGET_MODULES_DIR)/%,$(dir $(PERL_TARGET_MODS))); do \
			[ -d $$i ] || mkdir -p $$i; \
		done; \
		for i in $(PERL_TARGET_MODS); do \
			cp -dpf $(PERL_DIR)/lib/$$i $(PERL_TARGET_MODULES_DIR)/$$i; \
		done; \
	)
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_MODULES) $($(PKG)_TESTPACK)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PERL_DIR) -f Makefile clean
	-$(RM) -r $(PERL_TARGET_MODULES_DIR)
	-$(RM) $(PERL_TARGET_MODULES)
	-$(RM) $(PERL_DIR)/configure

$(pkg)-distclean: $(pkg)-clean
	-$(RM) -r -f $(PERL_DIR)

$(pkg)-uninstall:
	$(RM) $(PERL_TARGET_BINARY)
	$(RM) -r $(PERL_TARGET_MODULES_DIR)

$(PKG_FINISH)