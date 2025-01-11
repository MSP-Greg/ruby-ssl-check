# frozen_string_literal: true

require 'openssl'

module TestSSL
  class << self

    def run
      host = 'rubygems.org'
      ssl = ::OpenSSL::SSL
      tcp = TCPSocket.new host, 443

      ctx = ssl::SSLContext.new
      ctx.cert_store = ssl::SSLContext::DEFAULT_CERT_STORE
      ctx.verify_mode = ssl::VERIFY_PEER
      ctx.verify_hostname = true

      skt = ssl::SSLSocket.new tcp, ctx
      skt.connect

      skt.syswrite "GET / HTTP/1.1\r\ncache-control: no-cache\r\nhost: #{host}\r\n\r\n"

      resp = +''

      while tcp.wait_readable(1)
        resp << skt.sysread(16_384)
      end

      # simple response check
      hdrs, body = resp.split "\r\n\r\n", 2
      if hdrs.start_with? "HTTP/1.1 200 OK\r\n"
        puts "response status line is correct"
      else
        # error
      end
      if body.start_with?("<!DOCTYPE html>\n") && body.end_with?("</html>\n")
        puts "response body appears to be html"
      else
        # error
      end

    ensure
      skt&.close
      tcp&.close
    end

  end
end
TestSSL.run
