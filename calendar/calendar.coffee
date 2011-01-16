# Create a calendar table. See below for an example.

'Created by Maximillian Dornseif on 2011-01-16.'

util = require('util')

dayNames = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]

# **Find the ISO 8601 Weekday for a given date** - based on code from
# [jUI.datepoicker](http://jquery-ui.googlecode.com/svn/trunk/ui/jquery.ui.datepicker.js)
# keep in Mind, that the US 
# [uses a different System](http://en.wikipedia.org/wiki/Week_number#Week_numbering).
# 
# Accepts a JavaScript
# [Date Object](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date) as
# single parameter and returns a Number representing the ISO8601 Week Number of that Date.
iso8601Week = (date) ->
    # According to ISO 8601 'week 1' in a year is the first week containing a Thursday.
    # So we modify a copy of the Date Object. First we find the day of week, whereas we shift
    # from Sunday and 0 based indexing to monday and 1 based indexing.
    checkDate = new Date(date.getTime())
    weekday = checkDate.getDay() || 7
    # shift checkDate to be a Thursday
    checkDate.setDate(checkDate.getDate() + 4 - weekday)
    # Save checkDate as number of Milliseconds for later comparison
    time = checkDate.getTime()
    # Modify the `checkDate` to be January 1st of the given year.
    checkDate.setMonth(0)
    checkDate.setDate(1)
    diffDays = Math.round((time - checkDate) / 86400000)
    # The week number is now the number of days divided by seven
    # plus one to shift away from zero based indexing.
    return Math.floor(diffDays / 7) + 1


# **Generate structure for a monthly calendar**
# Accepts a JavaScript
# [Date Object](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date) as
# parameter and returns a list of lists with calendar information.
# You can give an additional Paramter `weekday_offset`. If set to `1` (default) weeks will start
# with monday. Setting it to `0` will result in Weeks starting with Sunday.

# Return value looks like this:
#
#     [ [ null, 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag', 'Montag']
#     , [ 52
#       , Mon, 27 Dec 2010 00:00:00 GMT
#       , Tue, 28 Dec 2010 00:00:00 GMT
#       , Wed, 29 Dec 2010 00:00:00 GMT
#       , Thu, 30 Dec 2010 00:00:00 GMT
#       , Fri, 31 Dec 2010 00:00:00 GMT
#       , Sat, 01 Jan 2011 00:00:00 GMT
#       , Sun, 02 Jan 2011 00:00:00 GMT
#       ]
#     , [ 1, Mon, 03 Jan 2011 00:00:00 GMT, ..., Sun, 09 Jan 2011 00:00:00 GMT]
#     , [ 2, Mon, 10 Jan 2011 00:00:00 GMT, ..., Sun, 16 Jan 2011 00:00:00 GMT]
#     , [ 3, Mon, 17 Jan 2011 00:00:00 GMT, ..., Sun, 23 Jan 2011 00:00:00 GMT]
#     , [ 4, Mon, 24 Jan 2011 00:00:00 GMT, ..., Sun, 30 Jan 2011 00:00:00 GMT]
#     , [ 5, Mon, 31 Jan 2011 00:00:00 GMT, ..., Sun, 06 Feb 2011 00:00:00 GMT]
#     ]
#
calendar_structure = (date, weekday_offset = 1) ->
    # First we generate a row with week day names. Currently the names are hardcoded.
    # The first collumn stays clear since it is reserved for the ISO Week number.
    header = [null]
    for i in [0..6]
        header.push(dayNames[(i + weekday_offset) % 7])
    rows = [header]
    
    # We have to find the first and the last day of the month, date is in. This works remarkably well
    # with JavaScript Date Objects, since they silently convert Input like `Date(2011, 0, 0)` to
    # `Date(2010, 11, 31)` (note: Months are 0-indexed in JS). We calculate `]prev;last]`.
    
    # The last day of this month is the 0th day of the next month.
    last = new Date(date.getFullYear(), date.getMonth()+1, 0).getDate()
    
    # The first day before this Month is the 0th day of this month.
    prev = new Date(date.getFullYear(), date.getMonth(), 0).getDate()
    
    # Calculate the day of week as an offset
    offset = ((date.getDay() - weekday_offset) + 7) % 7

    # Now geneerate the rows of the calendar. First we initilize the week Number with null - to mark
    # that it has to be filled in later, when we set up iterdate.
    row = [null]
    
    # We iterate over 42 days (6 x 7 or 6 weeks) to ensues we have covered all possible 
    # Overlap Scenarios (Week starts on Sunday, 31 Days)
    for i in [1..42]
        # Generate a Date Object based on our iteration variable. Ensure the weekday_offset is
        # taken into account. Per default this results in Monday as a week start.
        day = i - offset;
        iterdate = new Date(date.getFullYear(), date.getMonth(), day)
        # Check it we are at the beginning of a week. If so create a new empty row
        if (i - 1) % 7 == 0
            if row.length > 2
                rows.push(row)
            row = [null]
        
        # If the row has no week number set we add one. This is checked only now so we
        # already have initialized `iterdate`.
        if row[0] is null
            row[0] = iso8601Week(iterdate)
        
        # Add the current date to the row
        row.push(iterdate)

    # Push last row left over from the loop and return values.
    if row.length > 0
        rows.push(row)
    return rows


# **pad a numeric value to at least two digits**
pad = (n) ->
    ret = if n < 10 then '0' + n else n
    return ret


# **Generate a HTML calendar ready to be styled.** Output is a `<table>` marked up for
# CSS styling.
#
#     <table>
#       <thead class='wochentage'><tr>
#         <th class='week'></th>
#         <th>Montag</th><th>Dienstag</th>...<th>Sonntag</th>
#       </tr></thead>
#       <tbody>
#         <tr>
#           <th class='week kw52'>52</th>
#           <td class='decoration date20101227 day27 mo'>27</td>
#           <td class='decoration date20101228 day28 di'>28</td>
#           <td class='decoration date20101229 day29 mi'>29</td>
#           <td class='decoration date20101230 day30 do'>30</td>
#           <td class='decoration date20101231 day31 fr'>31</td>
#           <td class='current date20110101 day01 sa'>1</td>
#           <td class='current date20110102 day02 so'>2</td>
#         </tr>
#       ...
#       </tbody>
#     </table>


calendar_html = (date, weekday_offset = 1) ->
    # Calculate week days and save in `structure`. Put day nnames into `header`
    structure = calendar_structure(date, weekday_offset)
    header = structure[0][1..7]
    weeks = []
    # iterate over each week in the structure and peel of the ISO8601 week unmber information
    for week in structure[1..]
        kw = week[0]
        days = []
        # iterate over each day in the given week
        for day in week[1..]
            # Collect CSS class information for the given day
            cssclass = []
            # If the day is part of the month we calculate the calendar for, set it to 'current', else it
            # is just 'deccoration'
            if day.getMonth() == date.getMonth()
                cssclass.push('current')
            else
                cssclass.push('decoration')
            # Add ISO date and day number as CSS classes.
            cssclass.push('date' + day.getFullYear() + pad(day.getMonth() + 1) + pad(day.getDate()))
            cssclass.push('day' + pad(day.getDate()))
            # add first two letters of german day name as a CSS class
            cssclass.push(dayNames[day.getDay()].toLowerCase()[..1])
            # generate HTML for the day. Will look like `<td class='current date20110102 day02 so'>2</td>`.
            days.push("<td class='#{cssclass.join(' ')}'>#{day.getDate()}</td>\n")
        # Generate HTML for all days of the week and add it to the weeks array.
        weeks.push("<tr><th class='week kw#{kw}'>#{kw}</th>\n#{days.join('')}</tr>\n")
    # Generate HTML consisting of header and weeks array and return it.
    html = "<table>
<caption><span class='month'>January</span><span class='year'>#{date.getFullYear()}</span></caption>
<thead class='wochentage'><tr>\n
<th class='week'>KW</th>\n
<th>#{header.join('</th>\n<th>')}</th></tr></thead>
\n<tbody>\n#{weeks.join('')}\n</tbody></table>"
    return html
    
console.log(calendar_html(new Date(2011, 0, 15)))
