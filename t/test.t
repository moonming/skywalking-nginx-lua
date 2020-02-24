use Test::Nginx::Socket 'no_plan';

use Cwd qw(cwd);
my $pwd = cwd();

repeat_each(1);
no_long_string();
no_shuffle();
no_root_location();
log_level('info');

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/skywalking/?.lua;;";
    error_log logs/error.log debug;
    resolver 114.114.114.114 8.8.8.8 ipv6=off;

    lua_shared_dict tracing_buffer 100m;

    init_by_lua_block {

    }
};

run_tests;

__DATA__
=== TEST 1: Default HTTP port is not added to Host header
--- http_config eval: $::HttpConfig
--- config
    location /lua {
        content_by_lua '
            local http = require "resty.http"
            local httpc = http.new()
            local res, err = httpc:request_uri("http://www.baidu.com")
        ';
    }
--- request
GET /lua
--- no_error_log
[error]
