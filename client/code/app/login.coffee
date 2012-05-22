exports.login = (fn)->
  ss.rpc 'login.isLoggedin', (loggedIn)->
    if loggedIn
      fn(null,true)
    else
      $('#login_box').show()
      $('#login_form').submit ->
        ss.rpc 'login.login', $('#login_user').val(), $('#login_pass').val(), (result)->
          if result
            $('#login_box').hide()
            setTimeout -> fn(null,true)
          else
            alert('Неправильное имя пользователя или пароль')
        false
