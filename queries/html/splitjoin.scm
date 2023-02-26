(element
  (start_tag
    [ "<" ">" ] @splitjoin.html.angle
    (tag_name) @splitjoin.html.tag.void
    (attribute) @splitjoin.html.attr))

(element
  (start_tag
    [ "<" ">" ] @splitjoin.html.angle
    (tag_name) @splitjoin.html.tag.void))

(element
  (start_tag
    [ "<" ">" ] @splitjoin.html.angle
    (tag_name) @splitjoin.html.tag.start)
  (text) @splitjoin.html.text
  (end_tag) @splitjoin.html.tag.end)

(element
  (start_tag
    [ "<" ">" ] @splitjoin.html.angle
    (tag_name) @splitjoin.html.tag.start
    (attribute) @splitjoin.html.attr)
  (end_tag) @splitjoin.html.tag.end)

(element
  (start_tag
    [ "<" ">" ] @splitjoin.html.angle
    (tag_name) @splitjoin.html.tag.start
    (attribute) @splitjoin.html.attr)
  (text) @splitjoin.html.text
  (end_tag) @splitjoin.html.tag.end)

