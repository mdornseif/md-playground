(function() {
  'Created by Maximillian Dornseif on 2011-01-16.';  var calendar_html, calendar_structure, dayNames, iso8601Week, pad, util;
  util = require('util');
  dayNames = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"];
  iso8601Week = function(date) {
    var checkDate, diffDays, time, weekday;
    checkDate = new Date(date.getTime());
    weekday = checkDate.getDay() || 7;
    checkDate.setDate(checkDate.getDate() + 4 - weekday);
    time = checkDate.getTime();
    checkDate.setMonth(0);
    checkDate.setDate(1);
    diffDays = Math.round((time - checkDate) / 86400000);
    return Math.floor(diffDays / 7) + 1;
  };
  calendar_structure = function(date, weekday_offset) {
    var day, header, i, iterdate, last, offset, prev, row, rows;
    if (weekday_offset == null) {
      weekday_offset = 1;
    }
    header = [null];
    for (i = 0; i <= 6; i++) {
      header.push(dayNames[(i + weekday_offset) % 7]);
    }
    rows = [header];
    last = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
    prev = new Date(date.getFullYear(), date.getMonth(), 0).getDate();
    offset = ((date.getDay() - weekday_offset) + 7) % 7;
    row = [null];
    for (i = 1; i <= 42; i++) {
      day = i - offset;
      iterdate = new Date(date.getFullYear(), date.getMonth(), day);
      if ((i - 1) % 7 === 0) {
        if (row.length > 2) {
          rows.push(row);
        }
        row = [null];
      }
      if (row[0] === null) {
        row[0] = iso8601Week(iterdate);
      }
      row.push(iterdate);
    }
    if (row.length > 0) {
      rows.push(row);
    }
    return rows;
  };
  pad = function(n) {
    var ret;
    ret = n < 10 ? '0' + n : n;
    return ret;
  };
  calendar_html = function(date, weekday_offset) {
    var cssclass, day, days, header, html, kw, structure, week, weeks, _i, _j, _len, _len2, _ref, _ref2;
    if (weekday_offset == null) {
      weekday_offset = 1;
    }
    structure = calendar_structure(date, weekday_offset);
    header = structure[0].slice(1, 8);
    weeks = [];
    _ref = structure.slice(1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      week = _ref[_i];
      kw = week[0];
      days = [];
      _ref2 = week.slice(1);
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        day = _ref2[_j];
        cssclass = [];
        if (day.getMonth() === date.getMonth()) {
          cssclass.push('current');
        } else {
          cssclass.push('decoration');
        }
        cssclass.push('date' + day.getFullYear() + pad(day.getMonth() + 1) + pad(day.getDate()));
        cssclass.push('day' + pad(day.getDate()));
        cssclass.push(dayNames[day.getDay()].toLowerCase().slice(0, 2));
        days.push("<td class='" + (cssclass.join(' ')) + "'>" + (day.getDate()) + "</td>\n");
      }
      weeks.push("<tr><th class='week kw" + kw + "'>" + kw + "</th>\n" + (days.join('')) + "</tr>\n");
    }
    html = "<table><caption><span class='month'>January</span><span class='year'>" + (date.getFullYear()) + "</span></caption><thead class='wochentage'><tr>\n<th class='week'>KW</th>\n<th>" + (header.join('</th>\n<th>')) + "</th></tr></thead>\n<tbody>\n" + (weeks.join('')) + "\n</tbody></table>";
    return html;
  };
  console.log(calendar_html(new Date(2011, 0, 15)));
}).call(this);
