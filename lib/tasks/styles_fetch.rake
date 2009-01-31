namespace :styles do
  desc "Fetch common styles from github and install them in the local instance"
  task :fetch do
    sh "rm -rf tmp/style_clone"
    sh "git clone --depth 1 git://github.com/reidab/osbp_styles.git tmp/style_clone"
    sh "rsync -uvax --exclude='.git' --exclude='Rakefile' --exclude='README.markdown' tmp/style_clone/ themes/bridgepdx/stylesheets/common_css/"
    sh "rm -rf tmp/style_clone"
  end
end