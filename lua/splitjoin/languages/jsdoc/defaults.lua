local JSDoc = require'splitjoin.languages.jsdoc.functions'

---@type SplitjoinLanguageConfig
return {

  nodes = {

    description = {
      split = JSDoc.split_jsdoc_description,
      join = JSDoc.join_jsdoc_description,
      trailing_separator = false,
    },

  },

}
