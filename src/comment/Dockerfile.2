FROM alpine:3.7
RUN apk update \ 
    && apk --no-cache add --virtual bash ruby-dev build-base \
    && apk --no-cache add --virtual ruby ruby-bundler
    
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/
RUN bundle install
COPY . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
