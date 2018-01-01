TRAVIS_ELIXIR_VERSION="1.5.2"
TRAVIS_OTP_RELEASE="20.1"
export PLT_FILENAME=elixir-${TRAVIS_ELIXIR_VERSION}_${TRAVIS_OTP_RELEASE}.plt
export PLT_LOCATION=$HOME/$PLT_FILENAME
wget -O $PLT_LOCATION https://raw.github.com/danielberkompas/travis_elixir_plts/master/$PLT_FILENAME
export PROJECT_NAME=ex_structable
echo dialyzer --no_check_plt --plt $PLT_LOCATION --no_native _build/test/lib/$PROJECT_NAME/ebin
dialyzer --no_check_plt --plt $PLT_LOCATION --no_native _build/test/lib/$PROJECT_NAME/ebin
