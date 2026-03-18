post 'api/autologin_tokens', to: 'autologin_tokens#create'
delete 'api/autologin_tokens/:user_id', to: 'autologin_tokens#destroy'
get 'api/autologin_tokens/test', to: 'autologin_tokens#test'
