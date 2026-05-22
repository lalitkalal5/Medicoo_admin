$env:BUNDLE_USER_HOME='C:\Users\Admin\Documents\medicoo_admin\.bundle-home'
Set-Location 'C:\Users\Admin\Documents\medicoo_admin'
bundle exec ruby bin\rails server -p 3000 *> tmp\server.log
