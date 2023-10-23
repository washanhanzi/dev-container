FROM debian:bookworm

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y zsh git curl ripgrep sudo locales neovim unzip fontconfig nodejs npm

# add user
RUN adduser --disabled-password --gecos '' dev
RUN echo "dev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dev && \
	chmod 0440 /etc/sudoers.d/dev && \
	chown root:root /etc/sudoers.d/dev && \
	adduser dev sudo

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TERM xterm-256color

# set zsh as the default shell
RUN chsh -s /bin/zsh

USER dev
WORKDIR /home/dev

# Install Oh-My-Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Download, Unzip and Move fonts to correct folder
RUN sudo mkdir -p /usr/local/share/fonts
RUN cd /usr/local/share/fonts && sudo curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip && sudo unzip FiraCode.zip
RUN fc-cache -fv
RUN sudo rm /usr/local/share/fonts/FiraCode.zip

# power10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="powerlevel10k/powerlevel10k"|g' .zshrc

# setup zsh
COPY .zshrc .zshrc
RUN sudo chown dev:sudo .zshrc
COPY .p10k.zsh .p10k.zsh
RUN sudo chown dev:sudo .p10k.zsh
ENV SHELL /bin/zsh

# nvim
# go
# rust
RUN	curl https://sh.rustup.rs -sSf | sh -s -- -y

CMD ["zsh"]