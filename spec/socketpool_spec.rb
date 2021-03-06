require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SocketPool arguments" do
  describe SocketPool.new('127.0.0.1', '11222') do 
    specify { subject.port.should eq('11222')}
    specify { subject.host.should eq('127.0.0.1')}
    specify { subject.size.should eq(2)}
    specify { subject.timeout.should eq(5.0)}
    specify { subject.instance_variable_get(:@sockets).should eq([])}
    specify { subject.instance_variable_get(:@checked_out).should eq([])}
    specify { subject.instance_variable_get(:@pids).should eq({})}
    specify { subject.instance_variable_get(:@eager).should eq(false)}
    specify { subject.instance_variable_get(:@socktype).should eq(:tcp)}
    specify { subject.instance_variable_get(:@sockopts).should eq([])}
    
    it "should create socket on checkout" do 
      s = subject.checkout
      subject.instance_variable_get(:@sockets).should_not eq([])
      subject.instance_variable_get(:@sockets).size.should eq(1)
      subject.instance_variable_get(:@checked_out).size.should eq(1)

      subject.checkin(s)
      subject.instance_variable_get(:@checked_out).size.should eq(0)
    end    
  end

  describe "UDP => Eager SocketPool" do 
    subject { SocketPool.new('127.0.0.1', '11222', :type => :udp, :eager => true) }
    
    specify { subject.port.should eq('11222')}
    specify { subject.host.should eq('127.0.0.1')}
    specify { subject.size.should eq(2)}
    specify { subject.timeout.should eq(5.0)}
    specify { subject.instance_variable_get(:@sockets).size.should eq(2)}
    specify { subject.instance_variable_get(:@checked_out).should eq([])}
    specify { subject.instance_variable_get(:@eager).should eq(true)}
    specify { subject.instance_variable_get(:@socktype).should eq(:udp)}
    specify { subject.instance_variable_get(:@sockopts).should eq([])}    
  end

  describe "UDP => Eager SocketPool => resized, short timeout" do 
    subject { SocketPool.new('127.0.0.1', '11222', :type => :udp, :eager => true, :size => 19, :timeout => 1) }
    
    specify { subject.port.should eq('11222')}
    specify { subject.host.should eq('127.0.0.1')}
    specify { subject.size.should eq(19)}
    specify { subject.timeout.should eq(1.0)}
    specify { subject.instance_variable_get(:@sockets).size.should eq(19)}
    specify { subject.instance_variable_get(:@checked_out).should eq([])}
    specify { subject.instance_variable_get(:@eager).should eq(true)}
    specify { subject.instance_variable_get(:@socktype).should eq(:udp)}
    specify { subject.instance_variable_get(:@sockopts).should eq([])}    
  end

  describe "TCP => Eager SocketPool => resized, short timeout => TCP_NODELAY" do 
    subject { 
      SocketPool.new('127.0.0.1', '11222', 
        :type => :tcp, 
        :eager => true, 
        :size => 19, 
        :timeout => 1, 
        :socketopts => [{:level => Socket::IPPROTO_TCP, :optname => Socket::TCP_NODELAY, :optval => 1}]) 
    }
    
    specify { subject.port.should eq('11222')}
    specify { subject.host.should eq('127.0.0.1')}
    specify { subject.size.should eq(19)}
    specify { subject.timeout.should eq(1.0)}
    specify { subject.instance_variable_get(:@sockets).size.should eq(19)}
    specify { subject.instance_variable_get(:@checked_out).should eq([])}
    specify { subject.instance_variable_get(:@eager).should eq(true)}
    specify { subject.instance_variable_get(:@socktype).should eq(:tcp)}
    specify { subject.instance_variable_get(:@sockopts).should_not eq([])}    
  end
end
