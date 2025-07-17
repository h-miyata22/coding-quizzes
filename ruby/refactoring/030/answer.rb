# Interface Segregation - Split large interface into focused interfaces

# Core Interfaces
module Powerable
  def power_on
    raise NotImplementedError
  end

  def power_off
    raise NotImplementedError
  end

  def powered?
    raise NotImplementedError
  end
end

module VolumeControllable
  def set_volume(level)
    raise NotImplementedError
  end

  def volume
    raise NotImplementedError
  end

  def mute
    raise NotImplementedError
  end

  def unmute
    raise NotImplementedError
  end
end

module DisplayControllable
  def set_brightness(level)
    raise NotImplementedError
  end

  def brightness
    raise NotImplementedError
  end

  def set_resolution(resolution)
    raise NotImplementedError
  end

  def resolution
    raise NotImplementedError
  end
end

module ChannelControllable
  def set_channel(channel)
    raise NotImplementedError
  end

  def channel
    raise NotImplementedError
  end

  def channel_up
    raise NotImplementedError
  end

  def channel_down
    raise NotImplementedError
  end
end

module MediaPlayable
  def play(media_file = nil)
    raise NotImplementedError
  end

  def pause
    raise NotImplementedError
  end

  def stop
    raise NotImplementedError
  end
end

module Seekable
  def seek(position)
    raise NotImplementedError
  end

  def playback_position
    raise NotImplementedError
  end
end

module WiFiConnectable
  def connect_wifi(ssid, password)
    raise NotImplementedError
  end

  def disconnect_wifi
    raise NotImplementedError
  end

  def wifi_connected?
    raise NotImplementedError
  end
end

module BluetoothConnectable
  def connect_bluetooth(device_name)
    raise NotImplementedError
  end

  def disconnect_bluetooth
    raise NotImplementedError
  end

  def bluetooth_connected?
    raise NotImplementedError
  end
end

module AppInstallable
  def install_app(app_name)
    raise NotImplementedError
  end

  def uninstall_app(app_name)
    raise NotImplementedError
  end
end

module VoiceControllable
  def voice_command(command)
    raise NotImplementedError
  end
end

# Base Device Class
class BaseDevice
  include Powerable

  attr_reader :name, :type

  def initialize(name, type)
    @name = name
    @type = type
    @power_state = PowerState.new
  end

  def power_on
    @power_state.power_on
    puts "#{@name} powered on"
  end

  def power_off
    @power_state.power_off
    puts "#{@name} powered off"
  end

  def powered?
    @power_state.powered?
  end

  def device_info
    DeviceInfo.new(
      name: @name,
      type: @type,
      powered: powered?
    ).to_h
  end
end

# Concrete Device Classes
class Television < BaseDevice
  include VolumeControllable
  include DisplayControllable
  include ChannelControllable

  def initialize(name)
    super(name, 'tv')
    @volume_controller = VolumeController.new
    @display_controller = DisplayController.new
    @channel_controller = ChannelController.new
  end

  # VolumeControllable implementation
  def set_volume(level)
    @volume_controller.set_level(level)
    puts "#{@name} volume set to #{level}"
  end

  def volume
    @volume_controller.level
  end

  def mute
    @volume_controller.mute
    puts "#{@name} muted"
  end

  def unmute
    @volume_controller.unmute
    puts "#{@name} unmuted"
  end

  # DisplayControllable implementation
  def set_brightness(level)
    @display_controller.set_brightness(level)
    puts "#{@name} brightness set to #{level}"
  end

  def brightness
    @display_controller.brightness
  end

  def set_resolution(resolution)
    @display_controller.set_resolution(resolution)
    puts "#{@name} resolution set to #{resolution}"
  end

  def resolution
    @display_controller.resolution
  end

  # ChannelControllable implementation
  def set_channel(channel)
    @channel_controller.set_channel(channel)
    puts "#{@name} channel set to #{channel}"
  end

  def channel
    @channel_controller.current_channel
  end

  def channel_up
    @channel_controller.channel_up
    puts "#{@name} channel up to #{channel}"
  end

  def channel_down
    @channel_controller.channel_down
    puts "#{@name} channel down to #{channel}"
  end

  def device_info
    super.merge(
      volume: volume,
      brightness: brightness,
      channel: channel,
      resolution: resolution
    )
  end
end

class SmartTelevision < Television
  include WiFiConnectable
  include AppInstallable
  include VoiceControllable

  def initialize(name)
    super(name)
    @type = 'smart_tv'
    @network_controller = NetworkController.new
    @app_manager = AppManager.new
    @voice_controller = VoiceController.new
  end

  # WiFiConnectable implementation
  def connect_wifi(ssid, password)
    @network_controller.connect_wifi(ssid, password)
    puts "#{@name} connected to WiFi: #{ssid}"
  end

  def disconnect_wifi
    @network_controller.disconnect_wifi
    puts "#{@name} disconnected from WiFi"
  end

  def wifi_connected?
    @network_controller.wifi_connected?
  end

  # AppInstallable implementation
  def install_app(app_name)
    @app_manager.install(app_name)
    puts "#{@name} installing app: #{app_name}"
  end

  def uninstall_app(app_name)
    @app_manager.uninstall(app_name)
    puts "#{@name} uninstalling app: #{app_name}"
  end

  # VoiceControllable implementation
  def voice_command(command)
    @voice_controller.process_command(command)
    puts "#{@name} processing voice command: #{command}"
  end

  def device_info
    super.merge(
      wifi_connected: wifi_connected?,
      installed_apps: @app_manager.installed_apps
    )
  end
end

class MediaPlayer < BaseDevice
  include VolumeControllable
  include MediaPlayable
  include Seekable

  def initialize(name)
    super(name, 'media_player')
    @volume_controller = VolumeController.new
    @media_controller = MediaController.new
  end

  # VolumeControllable implementation
  def set_volume(level)
    @volume_controller.set_level(level)
    puts "#{@name} volume set to #{level}"
  end

  def volume
    @volume_controller.level
  end

  def mute
    @volume_controller.mute
    puts "#{@name} muted"
  end

  def unmute
    @volume_controller.unmute
    puts "#{@name} unmuted"
  end

  # MediaPlayable implementation
  def play(media_file = nil)
    @media_controller.play(media_file)
    puts "#{@name} playing #{@media_controller.current_media}"
  end

  def pause
    @media_controller.pause
    puts "#{@name} paused"
  end

  def stop
    @media_controller.stop
    puts "#{@name} stopped"
  end

  # Seekable implementation
  def seek(position)
    @media_controller.seek(position)
    puts "#{@name} seeked to #{position}"
  end

  def playback_position
    @media_controller.position
  end

  def device_info
    super.merge(
      volume: volume,
      current_media: @media_controller.current_media,
      position: playback_position
    )
  end
end

class Speaker < BaseDevice
  include VolumeControllable
  include MediaPlayable
  include BluetoothConnectable

  def initialize(name)
    super(name, 'speaker')
    @volume_controller = VolumeController.new
    @media_controller = MediaController.new
    @bluetooth_controller = BluetoothController.new
  end

  # VolumeControllable implementation
  def set_volume(level)
    @volume_controller.set_level(level)
    puts "#{@name} volume set to #{level}"
  end

  def volume
    @volume_controller.level
  end

  def mute
    @volume_controller.mute
    puts "#{@name} muted"
  end

  def unmute
    @volume_controller.unmute
    puts "#{@name} unmuted"
  end

  # MediaPlayable implementation
  def play(media_file = nil)
    @media_controller.play(media_file)
    puts "#{@name} playing #{@media_controller.current_media}"
  end

  def pause
    @media_controller.pause
    puts "#{@name} paused"
  end

  def stop
    @media_controller.stop
    puts "#{@name} stopped"
  end

  # BluetoothConnectable implementation
  def connect_bluetooth(device_name)
    @bluetooth_controller.connect(device_name)
    puts "#{@name} connected to Bluetooth device: #{device_name}"
  end

  def disconnect_bluetooth
    @bluetooth_controller.disconnect
    puts "#{@name} disconnected from Bluetooth"
  end

  def bluetooth_connected?
    @bluetooth_controller.connected?
  end

  def device_info
    super.merge(
      volume: volume,
      bluetooth_connected: bluetooth_connected?
    )
  end
end

class SmartSpeaker < Speaker
  include WiFiConnectable
  include VoiceControllable

  def initialize(name)
    super(name)
    @type = 'smart_speaker'
    @network_controller = NetworkController.new
    @voice_controller = VoiceController.new
  end

  # WiFiConnectable implementation
  def connect_wifi(ssid, password)
    @network_controller.connect_wifi(ssid, password)
    puts "#{@name} connected to WiFi: #{ssid}"
  end

  def disconnect_wifi
    @network_controller.disconnect_wifi
    puts "#{@name} disconnected from WiFi"
  end

  def wifi_connected?
    @network_controller.wifi_connected?
  end

  # VoiceControllable implementation
  def voice_command(command)
    @voice_controller.process_command(command)
    puts "#{@name} processing voice command: #{command}"
  end

  def device_info
    super.merge(
      wifi_connected: wifi_connected?
    )
  end
end

# Controller Classes (Single Responsibility)
class PowerState
  def initialize
    @powered = false
  end

  def power_on
    @powered = true
  end

  def power_off
    @powered = false
  end

  def powered?
    @powered
  end
end

class VolumeController
  INITIAL_VOLUME = 50
  MAX_VOLUME = 100
  MIN_VOLUME = 0

  def initialize
    @level = INITIAL_VOLUME
    @previous_level = INITIAL_VOLUME
  end

  def set_level(level)
    @level = [[level, MAX_VOLUME].min, MIN_VOLUME].max
  end

  attr_reader :level

  def mute
    @previous_level = @level
    @level = MIN_VOLUME
  end

  def unmute
    @level = @previous_level
  end
end

class DisplayController
  DEFAULT_BRIGHTNESS = 80
  DEFAULT_RESOLUTION = '1080p'

  def initialize
    @brightness = DEFAULT_BRIGHTNESS
    @resolution = DEFAULT_RESOLUTION
  end

  def set_brightness(level)
    @brightness = [[level, 100].min, 0].max
  end

  attr_reader :brightness, :resolution

  def set_resolution(resolution)
    @resolution = resolution
  end
end

class ChannelController
  INITIAL_CHANNEL = 1

  def initialize
    @current_channel = INITIAL_CHANNEL
  end

  def set_channel(channel)
    @current_channel = [channel, 1].max
  end

  attr_reader :current_channel

  def channel_up
    @current_channel += 1
  end

  def channel_down
    @current_channel = [@current_channel - 1, 1].max
  end
end

class MediaController
  def initialize
    @current_media = nil
    @position = 0
    @state = :stopped
  end

  def play(media_file = nil)
    @current_media = media_file if media_file
    @state = :playing
  end

  def pause
    @state = :paused
  end

  def stop
    @state = :stopped
    @position = 0
  end

  def seek(position)
    @position = [position, 0].max
  end

  attr_reader :current_media, :position, :state
end

class NetworkController
  def initialize
    @wifi_connected = false
    @connected_ssid = nil
  end

  def connect_wifi(ssid, _password)
    # Simulate connection logic
    @wifi_connected = true
    @connected_ssid = ssid
  end

  def disconnect_wifi
    @wifi_connected = false
    @connected_ssid = nil
  end

  def wifi_connected?
    @wifi_connected
  end

  attr_reader :connected_ssid
end

class BluetoothController
  def initialize
    @connected = false
    @connected_device = nil
  end

  def connect(device_name)
    @connected = true
    @connected_device = device_name
  end

  def disconnect
    @connected = false
    @connected_device = nil
  end

  def connected?
    @connected
  end

  attr_reader :connected_device
end

class AppManager
  def initialize
    @installed_apps = []
  end

  def install(app_name)
    @installed_apps << app_name unless @installed_apps.include?(app_name)
  end

  def uninstall(app_name)
    @installed_apps.delete(app_name)
  end

  def installed_apps
    @installed_apps.dup
  end
end

class VoiceController
  def initialize
    @command_history = []
  end

  def process_command(command)
    @command_history << { command: command, timestamp: Time.now }
    # Process command logic here
  end

  def command_history
    @command_history.dup
  end
end

class DeviceInfo
  def initialize(name:, type:, powered:)
    @name = name
    @type = type
    @powered = powered
  end

  def to_h
    {
      name: @name,
      type: @type,
      powered: @powered
    }
  end
end

# Client Classes with Focused Dependencies
class BasicRemoteControl
  def initialize(device)
    unless device.is_a?(Powerable) && device.is_a?(VolumeControllable)
      raise ArgumentError, 'Device must support power and volume control'
    end

    @device = device
  end

  def power_toggle
    if @device.powered?
      @device.power_off
    else
      @device.power_on
    end
  end

  def volume_up
    current = @device.volume
    @device.set_volume(current + 10)
  end

  def volume_down
    current = @device.volume
    @device.set_volume(current - 10)
  end
end

class TVRemoteControl < BasicRemoteControl
  def initialize(device)
    raise ArgumentError, 'Device must support channel control' unless device.is_a?(ChannelControllable)

    super(device)
  end

  def change_channel(channel)
    @device.set_channel(channel)
  end

  def channel_up
    @device.channel_up
  end

  def channel_down
    @device.channel_down
  end
end

class MediaRemoteControl < BasicRemoteControl
  def initialize(device)
    raise ArgumentError, 'Device must support media playback' unless device.is_a?(MediaPlayable)

    super(device)
  end

  def play_media(file)
    @device.play(file)
  end

  def pause
    @device.pause
  end

  def stop
    @device.stop
  end
end

class SeekableMediaController < MediaRemoteControl
  def initialize(device)
    raise ArgumentError, 'Device must support seeking' unless device.is_a?(Seekable)

    super(device)
  end

  def seek_to(position)
    @device.seek(position)
  end

  def current_position
    @device.playback_position
  end
end

class NetworkManager
  def initialize(device)
    @device = device
  end

  def setup_wifi(ssid, password)
    raise UnsupportedOperation, 'Device does not support WiFi' unless @device.is_a?(WiFiConnectable)

    @device.connect_wifi(ssid, password)
  end

  def setup_bluetooth(device_name)
    raise UnsupportedOperation, 'Device does not support Bluetooth' unless @device.is_a?(BluetoothConnectable)

    @device.connect_bluetooth(device_name)
  end
end

class SmartDeviceManager
  def initialize(device)
    @device = device
  end

  def install_app(app_name)
    raise UnsupportedOperation, 'Device does not support app installation' unless @device.is_a?(AppInstallable)

    @device.install_app(app_name)
  end

  def voice_command(command)
    raise UnsupportedOperation, 'Device does not support voice commands' unless @device.is_a?(VoiceControllable)

    @device.voice_command(command)
  end
end

# Factory for creating devices
class DeviceFactory
  def self.create_television(name)
    Television.new(name)
  end

  def self.create_smart_television(name)
    SmartTelevision.new(name)
  end

  def self.create_media_player(name)
    MediaPlayer.new(name)
  end

  def self.create_speaker(name)
    Speaker.new(name)
  end

  def self.create_smart_speaker(name)
    SmartSpeaker.new(name)
  end
end

# Custom Exceptions
class UnsupportedOperation < StandardError; end
class InvalidDeviceType < StandardError; end
