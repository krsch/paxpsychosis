exports.login = (fn)->
  ss.rpc 'login.isLoggedin', (err, loggedIn)->
    if !err && loggedIn
      fn(null,true)
    else
      $('#login_box').show()
      $('#form-auth').submit ->
        ss.rpc 'login.login', $('#login').val(), $('#pass').val(), (err,result)->
          if result
            $('#login_box').hide()
            fn(null,true)
          else
            alert('Неправильное имя пользователя или пароль')
        false
exports.logout = (fn)->
  ss.rpc 'login.logout', (res)->
    if res
      fn(null,null)
    else
      fn(-1, null)
