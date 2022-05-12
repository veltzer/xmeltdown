import datetime
import config.general

project_name = "xmeltdown"
project_long_description = """When I was back in the UNI I used to move people away from machine by running
xmeltdown on their machines. The user is happily working on his machine and
suddenly the whole screen seems to melt. All you need to run this is X access
to his screen (xhost + on his side). Some systems are configured (stupidly)
that way so we can play our little tricks on them. Cut to some years later
and I wanted to run this xmeltdown again. I searched for some RPM or source
package but to no avail. I stumbled across a set of old source on some http
server in MIT and rescued them from obscurity. A lot of compilation fixes
and some cleanups and bug fixes went into this and you can happily run
xmeltdown again. Copyright of most of the stuff still belongs to the
original authors. Free source never dies."""
project_year_started = 2002
project_description = "utilities for X11"

project_copyright_years = ", ".join(
    map(str, range(int(project_year_started), datetime.datetime.now().year + 1)))
if str(config.general.general_current_year) == project_year_started:
    project_copyright_years = config.general.general_current_year
else:
    project_copyright_years = f"{project_year_started} - {config.general.general_current_year}"
