local HTML = require'splitjoin.languages.html.functions'


---@type SplitjoinLanguageOptions
return {

  nodes = {

    tag_name = {
      split = HTML.split,
      join = HTML.join,
    },

    attribute = {
      split = HTML.split,
      join = HTML.join,
    },

    text = {
      split = HTML.split,
      join = HTML.join,
    },

    start_tag = {
      split = HTML.split,
      join = HTML.join,
    },

    end_tag = {
      split = HTML.split,
      join = HTML.join,
    },

  },

}
