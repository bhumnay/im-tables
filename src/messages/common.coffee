module.exports =
  All: 'All'
  Reset: 'Reset'
  Export: "Download"
  Clear: 'Clear'
  Cancel: 'Cancel'
  Complete: 'Complete'
  Error: 'Error'
  Warning: 'Warning'
  Filter: 'Filter'
  and: 'and'
  or: 'or'
  comma: ','
  Number: '<%= formatNumber(n) %>' # can be used in templates to access formatNumber
  'modal.DefaultTitle': 'Excuse me...'
  'modal.Dismiss': 'Close'
  'modal.OK': 'OK'
  'core.NoOptions': 'There are no options to select from.'
  ErrorTitle: ({level}) -> switch level
    when 'Error' then 'Error'
    when 'Warning' then 'Warning'
    when 'Info' then 'nb'
    when 'Positive' then 'Success'
    else 'Error'
