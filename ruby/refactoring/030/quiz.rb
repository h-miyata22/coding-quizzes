class MultimediaDevice
  def initialize(name, type)
    @name = name
    @type = type
    @is_powered = false
    @volume = 50
    @brightness = 80
    @channel = 1
    @resolution = '1080p'
    @media_file = nil
    @playback_position = 0
    @wifi_connected = false
    @bluetooth_connected = false
  end

  def power_on
    @is_powered = true
    puts "#{@name} powered on"
  end

  def power_off
    @is_powered = false
    puts "#{@name} powered off"
  end

  def is_powered?
    @is_powered
  end

  def set_volume(level)
    @volume = level
    puts "#{@name} volume set to #{level}"
  end

  def get_volume
    @volume
  end

  def mute
    @previous_volume = @volume
    @volume = 0
    puts "#{@name} muted"
  end

  def unmute
    @volume = @previous_volume || 50
    puts "#{@name} unmuted"
  end

  def set_brightness(level)
    if @type == 'tv' || @type == 'monitor'
      @brightness = level
      puts "#{@name} brightness set to #{level}"
    else
      puts "#{@name} does not support brightness control"
    end
  end

  def get_brightness
    if @type == 'tv' || @type == 'monitor'
      @brightness
    else
      puts "#{@name} does not support brightness control"
      nil
    end
  end

  def set_resolution(resolution)
    if @type == 'tv' || @type == 'monitor'
      @resolution = resolution
      puts "#{@name} resolution set to #{resolution}"
    else
      puts "#{@name} does not support resolution control"
    end
  end

  def set_channel(channel)
    if @type == 'tv'
      @channel = channel
      puts "#{@name} channel set to #{channel}"
    else
      puts "#{@name} does not support channel control"
    end
  end

  def get_channel
    if @type == 'tv'
      @channel
    else
      puts "#{@name} does not support channel control"
      nil
    end
  end

  def channel_up
    if @type == 'tv'
      @channel += 1
      puts "#{@name} channel up to #{@channel}"
    else
      puts "#{@name} does not support channel control"
    end
  end

  def channel_down
    if @type == 'tv'
      @channel -= 1 if @channel > 1
      puts "#{@name} channel down to #{@channel}"
    else
      puts "#{@name} does not support channel control"
    end
  end

  def play(media_file = nil)
    if @type == 'media_player' || @type == 'speaker'
      @media_file = media_file if media_file
      puts "#{@name} playing #{@media_file}"
    else
      puts "#{@name} does not support media playback"
    end
  end

  def pause
    if @type == 'media_player' || @type == 'speaker'
      puts "#{@name} paused"
    else
      puts "#{@name} does not support media playback"
    end
  end

  def stop
    if @type == 'media_player' || @type == 'speaker'
      @playback_position = 0
      puts "#{@name} stopped"
    else
      puts "#{@name} does not support media playback"
    end
  end

  def seek(position)
    if @type == 'media_player'
      @playback_position = position
      puts "#{@name} seeked to #{position}"
    else
      puts "#{@name} does not support seeking"
    end
  end

  def get_playback_position
    if @type == 'media_player'
      @playback_position
    else
      nil
    end
  end

  def connect_wifi(ssid, password)
    if @type == 'smart_tv' || @type == 'smart_speaker'
      @wifi_connected = true
      puts "#{@name} connected to WiFi: #{ssid}"
    else
      puts "#{@name} does not support WiFi"
    end
  end

  def disconnect_wifi
    if @type == 'smart_tv' || @type == 'smart_speaker'
      @wifi_connected = false
      puts "#{@name} disconnected from WiFi"
    else
      puts "#{@name} does not support WiFi"
    end
  end

  def is_wifi_connected?
    if @type == 'smart_tv' || @type == 'smart_speaker'
      @wifi_connected
    else
      false
    end
  end

  def connect_bluetooth(device_name)
    if @type == 'speaker' || @type == 'smart_speaker'
      @bluetooth_connected = true
      puts "#{@name} connected to Bluetooth device: #{device_name}"
    else
      puts "#{@name} does not support Bluetooth"
    end
  end

  def disconnect_bluetooth
    if @type == 'speaker' || @type == 'smart_speaker'
      @bluetooth_connected = false
      puts "#{@name} disconnected from Bluetooth"
    else
      puts "#{@name} does not support Bluetooth"
    end
  end

  def is_bluetooth_connected?
    if @type == 'speaker' || @type == 'smart_speaker'
      @bluetooth_connected
    else
      false
    end
  end

  def install_app(app_name)
    if @type == 'smart_tv'
      puts "#{@name} installing app: #{app_name}"
    else
      puts "#{@name} does not support app installation"
    end
  end

  def uninstall_app(app_name)
    if @type == 'smart_tv'
      puts "#{@name} uninstalling app: #{app_name}"
    else
      puts "#{@name} does not support app installation"
    end
  end

  def voice_command(command)
    if @type == 'smart_tv' || @type == 'smart_speaker'
      puts "#{@name} processing voice command: #{command}"
    else
      puts "#{@name} does not support voice commands"
    end
  end

  def get_device_info
    {
      name: @name,
      type: @type,
      powered: @is_powered,
      volume: @volume,
      brightness: @brightness,
      channel: @channel,
      resolution: @resolution,
      wifi_connected: @wifi_connected,
      bluetooth_connected: @bluetooth_connected
    }
  end
end

class RemoteControl
  def initialize(device)
    @device = device
  end

  def power_toggle
    if @device.is_powered?
      @device.power_off
    else
      @device.power_on
    end
  end

  def volume_up
    current = @device.get_volume
    @device.set_volume(current + 10)
  end

  def change_channel(channel)
    @device.set_channel(channel)
  end
end

class MediaController
  def initialize(device)
    @device = device
  end

  def play_media(file)
    @device.play(file)
  end

  def control_playback(action)
    case action
    when 'pause'
      @device.pause
    when 'stop'
      @device.stop
    end
  end
end

class NetworkManager
  def initialize(device)
    @device = device
  end

  def setup_wifi(ssid, password)
    @device.connect_wifi(ssid, password)
  end

  def setup_bluetooth(device_name)
    @device.connect_bluetooth(device_name)
  end
end
