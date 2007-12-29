#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - sed scripts
# --------------------------------------------------------------------------------

# ----------------------------------------
# files
# ----------------------------------------
SED_HTML2TXT="$DTMFBOX_PATH/tmp/html2txt.sed"
SED_WEATHER="$DTMFBOX_PATH/tmp/weather.sed"
SED_TOLOWER="$DTMFBOX_PATH/tmp/tolower.sed"
SED_NO2WORD="$DTMFBOX_PATH/tmp/no2word.sed"


# HTML-to-TXT
# ----------------------------------------
sed_html2txt()
{
if [ ! -f "$SED_HTML2TXT" ];
then
cat << EOF > "$SED_HTML2TXT"
# remove html tags
s/^.*<body*>//g;
s/<a.*href.*>.*<\/a>/ /g;
s/<[^>]*>/\n/g;/</N;
s/<[^>]*>/\n/g;

# für ä besser e
s/&auml;/e/g;
s/&Auml;/Ae/g;
s/&uuml;/ue/g;
s/&Uuml;/Ue/g;
s/&ouml;/oe/g;
s/&Ouml;/Oe/g;
s/&szlig;/ss/g;
s/&quot;/"/g;
s/&amp;/ und /g;
s/&lt;/ kleiner /g;
s/&gt;/ groesser /g;
s/&nbsp;/ /g;
s/&deg;C/ Grad. - /g;

s/[[:cntrl:]]/ /g;
/^ *$/d
p;
EOF
fi
}

# PDA-Wetter
# ----------------------------------------
sed_weather()
{
if [ ! -f "$SED_WEATHER" ];
then
cat << EOF > "$SED_WEATHER"
# tags
/wetteron/d;

# und zum Anpassen der Ausgabe von wap.wetteronline.de...
# Datum durch Doppelpunkt ersetzen
s/[, [:digit:]]*[.][[:digit:]]*[.]/:/g;

# diverse Ersetzungen
s/\([:,.]\)\([[:alnum:]]\)/\1 \2/g;
s/ -\([[:digit:]]\)/ minus \1/g;
s/ - \([[:digit:]]\)/ minus \1/g;
s/--/./g;
s/ 1 / ein /g;
s/z. B./zum Beispiel/g;
s/Vorhersage fuer /. /g;
s/Vorhersage \(.*\)/\1./g;
s/Deutschland,.*//g;

# Min/Max ersetzen
s/Min:/mieni mal:/g;
s/Max:/maxi mal:/g;

# Satzzeichen ergänzen
s/Nachmittag/. Nachmittag/g;
s/Vorhersage/. Vorhersage/g;
s/WetterOnline/:/g;
p;
EOF
fi
}

# Number-To-Word
# ----------------------------------------
sed_no2word()
{
if [ ! -f "$SED_NO2WORD" ];
then
cat << EOF > "$SED_NO2WORD"
s/30\./ dreissigste/g;
s/31\./ einunddreissigste/g;

s/20\./ zwanzigste/g;
s/21\./ einundzwanzigste/g;
s/22\./ zweiundzwanzigste/g;
s/23\./ dreiundzwanzigste/g;
s/24\./ vierundzwanzigste/g;
s/25\./ fuenfundzwanzigste/g;
s/26\./ sechsundzwanzigste/g;
s/27\./ siebenundzwanzigste/g;
s/28\./ achtundzwanzigste/g;
s/29\./ neunundzwanzigste/g;

s/10\./ zehnte/g;
s/11\./ elfte/g;
s/12\./ zwoelfte/g;
s/13\./ dreizehnte/g;
s/14\./ vierzehnte/g;
s/15\./ fuenfzehnte/g;
s/16\./ sechszehnte/g;
s/17\./ siebzehnte/g;
s/18\./ achtzehnte/g;
s/19\./ neunzehnte/g;

s/1\./ erste/g;
s/2\./ zweite/g;
s/3\./ dritte/g;
s/4\./ vierte/g;
s/5\./ fuenfte/g;
s/6\./ sechste/g;
s/7\./ siebte/g;
s/8\./ achte/g;
s/9\./ neunte/g;

s/([[:digit:]])\./ \1'ste/g;

p;
EOF
fi
}

# UpperCase-To-LowerCase
# ----------------------------------------
sed_tolower()
{
if [ ! -f "$SED_TOLOWER" ];
then
cat << EOF > "$SED_TOLOWER"
y/ABCDEFGHIJKLMNOPQRSTUVWXYZÖÄÜ/abcdefghijklmnopqrstuvwxyzöäü/;
p;
EOF
fi
}
