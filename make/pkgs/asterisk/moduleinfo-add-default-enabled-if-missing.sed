# this script adds <defaultenabled>yes</defaultenabled> xml-element to an asterisk source file if it's missing
:loop
/^\/[*]{3}[ \t]+MODULEINFO/,/[ \t]*[*]{3}\// {
  /[ \t]*[*]{3}\//!{
    $!{
      N;
      bloop
    }
  }
  /<defaultenabled>(no|yes)<\/defaultenabled>/!{
    s,(\t<support_level>[^<]+<\/support_level>),\t<defaultenabled>yes<\/defaultenabled>\n\1,
  }
}
