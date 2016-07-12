# http://www.freedesktop.org/software/systemd/man/systemd.automount.html
#
# Cookbook Name:: systemd
# Module:: Automount
#
# Copyright 2015 The Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'pathname'

module Systemd
  UNIT_TYPES ||= %w(
    automount
    device
    mount
    path
    scope
    service
    slice
    socket
    swap
    target
    timer
  )

  module Common
    ABSOLUTE_PATH ||= {
      kind_of: String,
      callbacks: {
        'is an absolute path' => -> (spec) { Pathname.new(spec).absolute? }
      }
    }.freeze
    SOFT_ABSOLUTE_PATH ||= {
      kind_of: String,
      callbacks: {
        'is an absolute path' => lambda do |spec|
          Pathname.new(spec.gsub(/^\-/, '')).absolute?
        end
      }
    }.freeze
    ARCH ||= {
      kind_of: String,
      equal_to: %w(
        x86
        x86-64
        ppc
        ppc-le
        ppc64
        ppc64-le
        ia64
        parisc
        parisc64
        s390
        s390x
        sparc
        sparc64
        mips
        mips-le
        mips64
        mips64-le
        alpha
        arm
        arm-be
        arm64
        arm64-be
        sh
        sh64
        m86k
        tilegx
        cris
      )
    }.freeze
    ARRAY ||= { kind_of: [String, Array] }
    ARRAY_OF_ABSOLUTE_PATHS ||= {
      kind_of: [String, Array],
      callbacks: {
        'is an absolute path' => lambda do |spec|
          Array(spec).all? { |p| Pathname.new(p).absolute? }
        end
      }
    }.freeze
    ARRAY_OF_SOFT_ABSOLUTE_PATHS |= {
      kind_of: [String, Array],
      callbacks: {
        'has valid arguments' => lambda do |spec|
          Array(spec).all? { |p| Pathname.new(p.gsub(/^\-/, '')).absolute? }
        end
      }
    }.freeze
    ARRAY_OF_UNITS ||= {
      kind_of: [String, Array],
      callbacks: {
        'contains only valid unit names' => lambda do |spec|
           Array(spec).all? { |u| UNIT_TYPES.any? { |t| u.end_with?(t) } }
        end
      }
    }.freeze
    ARRAY_OF_URIS ||= {
      kind_of: Array,
      callbacks: {
        'contains only valid URIs' => lambda do |spec|
          spec.all? { |u| u =~ /\A#{URI::regexp}\z/ }
        end
      }
    }
    BOOLEAN ||= { kind_of: [TrueClass, FalseClass] }.freeze
    CAP ||= {
      kind_of: [String, Array],
      callbacks: {
        'matches capability string' => lambda do |spec|
          Array(spec).all? { |s| s.match(/^(!)?CAP_([A-Z_]+)?[A-Z]+$/) }
        end
      }
    }.freeze
    CONDITIONAL_PATH ||= {
      kind_of: String,
      callbacks: {
        'is empty string or a (piped/negated) absolute path' => lambda do |spec|
          spec.empty? || Pathname.new(spec.gsub(/(\||!)/, '')).absolute?
        end
      }
    }.freeze
    INTEGER ||= { kind_of: Integer }.freeze
    POWER ||= {
      kind_of: String,
      equal_to: %w(
        none
        reboot
        reboot-force
        reboot-immediate
        poweroff
        poweroff-force
        poweroff-immediate
      )
    }.freeze
    SECURITY ||= {
      kind_of: String,
      equal_to: %w( selinux apparmor ima smack audit )
    }.freeze
    STRING ||= { kind_of: String }.freeze
    STRING_OR_ARRAY ||= { kind_of: [String, Array] }.freeze
    STRING_OR_INT ||= { kind_of: [String, Integer] }.freeze
    UNIT ||= {
      kind_of: String,
      callbacks: {
        'is a unit name' => lambda do |spec|
          UNIT_TYPES.any? { |t| spec.end_with?(t) }
        end
      }
    }.freeze
    VIRT ||= {
      kind_of: String,
      equal_to: %w(
        qemu
        kvm
        zvm
        vmware
        microsoft
        oracle
        xen
        bochs
        uml
        openvz
        lxc
        lxc-libvirt
        systemd-nspawn
        docker
        rkt
      )
    }.freeze
  end

  module Unit
    OPTIONS ||= {
      'Unit' => {
        'Description' => Common::STRING,
        'Documentation' => Common::ARRAY_OF_URIS,
        'Requires' => Common::ARRAY_OF_UNITS, 
        'Requisite' => Common::ARRAY_OF_UNITS,
        'Wants' => Common::ARRAY_OF_UNITS,
        'BindsTo' => Common::ARRAY_OF_UNITS,
        'PartOf' => Common::ARRAY_OF_UNITS,
        'Conflicts' => Common::ARRAY_OF_UNITS,
        'Before' => Common::ARRAY_OF_UNITS,
        'After' => Common::ARRAY_OF_UNITS,
        'OnFailure' => Common::ARRAY_OF_UNITS,
        'PropagatesReloadTo' => Common::ARRAY_OF_UNITS,
        'ReloadPropagatedFrom' => Common::ARRAY_OF_UNITS,
        'JoinsNamespaceOf' => Common::ARRAY_OF_UNITS,
        'RequiresMountsFor' => Common::ARRAY_OF_ABSOLUTE_PATHS,
        'OnFailureJobMode' => {
          kind_of: String,
          equal_to: %w(
            fail
            replace
            replace-irreversibly
            isolate
            flush
            ignore-dependencies
            ignore-requirements
          )
        },
        'IgnoreOnIsolate' => Common::BOOLEAN,
        'StopWhenUnneeded' => Common::BOOLEAN,
        'RefuseManualStart' => Common::BOOLEAN,
        'RefuseManualStop' => Common::BOOLEAN,
        'AllowIsolate' => Common::BOOLEAN,
        'DefaultDependencies' => Common::BOOLEAN,
        'JobTimeoutSec' => Common::STRING_OR_INT,
        'JobTimeoutAction' => Common::POWER,
        'JobTimeoutRebootArgument' => Common::STRING,
        'StartLimitIntervalSec' => Common::STRING_OR_INT,
        'StartLimitBurst' => Common::INTEGER,
        'StartLimitAction' => Common::POWER,
        'RebootArgument' => Common::STRING,
        'ConditionArchitecture' => Common::ARCH,
        'ConditionVirtualization' => Common::VIRT,
        'ConditionHost' => Common::STRING,
        'ConditionKernelCommandLine' => Common::STRING,
        'ConditionSecurity' => Common::SECURITY,
        'ConditionCapability' => Common::CAP,
        'ConditionACPower' => Common::BOOLEAN,
        'ConditionNeedsUpdate' => {
          kind_of: String,
          equal_to: %w( /etc /var !/etc !/var )
        },
        'ConditionFirstBoot' => Common::BOOLEAN,
        'ConditionPathExists' => Common::CONDITIONAL_PATH,
        'ConditionPathExistsGlob' => Common::CONDITIONAL_PATH,
        'ConditionPathIsDirectory' => Common::CONDITIONAL_PATH,
        'ConditionPathIsSymbolicLink' => Common::CONDITIONAL_PATH,
        'ConditionPathIsMountPoint' => Common::CONDITIONAL_PATH,
        'ConditionPathIsReadWrite' => Common::CONDITIONAL_PATH,
        'ConditionDirectoryNotEmpty' => Common::CONDITIONAL_PATH,
        'ConditionFileNotEmpty' => Common::CONDITIONAL_PATH,
        'ConditionFileIsExecutable' => Common::CONDITIONAL_PATH,
        'AssertArchitecture' => Common::ARCH,
        'AssertVirtualization' => Common::VIRT,
        'AssertHost' => Common::STRING,
        'AssertKernelCommandLine' => Common::STRING,
        'AssertSecurity' => Common::SECURITY,
        'AssertCapability' => Common::CAP,
        'AssertACPower' => Common::BOOLEAN,
        'AssertNeedsUpdate' => {
          kind_of: String,
          equal_to: %w( /etc /var !/etc !/var )
        },
        'AssertFirstBoot' => Common::BOOLEAN,
        'AssertPathExists' => Common::CONDITIONAL_PATH,
        'AssertPathExistsGlob' => Common::CONDITIONAL_PATH,
        'AssertPathIsDirectory' => Common::CONDITIONAL_PATH,
        'AssertPathIsSymbolicLink' => Common::CONDITIONAL_PATH,
        'AssertPathIsMountPoint' => Common::CONDITIONAL_PATH,
        'AssertPathIsReadWrite' => Common::CONDITIONAL_PATH,
        'AssertDirectoryNotEmpty' => Common::CONDITIONAL_PATH,
        'AssertFileNotEmpty' => Common::CONDITIONAL_PATH,
        'AssertFileIsExecutable' => Common::CONDITIONAL_PATH,
        'SourcePath' => Systmd::Common::ABSOLUTE_PATH
      }
    }.freeze
  end

  module Install
    OPTIONS ||= {
      'Install' => {
        'Alias' => Common::ARRAY_OF_UNITS,
        'WantedBy' => Common::ARRAY_OF_UNITS,
        'RequiredBy' => Common::ARRAY_OF_UNITS,
        'Also' => Common::ARRAY_OF_UNITS,
        'DefaultInstance' => Common::STRING
      }
    }.freeze
  end

  module Exec
    OPTIONS ||= {
      'WorkingDirectory' => {
        kind_of: String,
        callbacks: {
          'is a valid working directory argument' => lambda do |spec|
            spec == '~' || Pathname.new(spec.gsub(/^-/, '')).absolute?
          end
        }
      },
      'RootDirectory' => Common::ABSOLUTE_PATH,
      'User' => Common::STRING_OR_INT,
      'Group' => Common::STRING_OR_INT,
      'SupplementaryGroups' => Common::ARRAY,
      'Nice' => { kind_of: Integer, equal_to: -20.upto(19).to_a },
      'OOMScoreAdjust' => { kind_of: Integer, equal_to: -1000.upto(1000).to_a },
      'IOSchedulingClass' => {
        kind_of: [Integer, String],
        equal_to: [0, 1, 2, 3, 'none', 'realtime', 'best-effort', 'idle']
      },
      'IOSchedulingPriority' => { kind_of: Integer, equal_to: 0.upto(7).to_a },
      'CPUSchedulingPolicy' => {
        kind_of: String,
        equal_to: %w( other batch idle fifo rr )
      },
      'CPUSchedulingPriority' => {
        kind_of: Integer,
        equal_to: 0.upto(99).to_a
      },
      'CPUSchedulingResetOnFork' => Common::BOOLEAN,
      'CPUAffinity' => { kind_of: [String, Integer, Array] },
      'UMask' => Common::STRING,
      'Environment' => { kind_of: [String, Array, Hash] },
      'EnvironmentFile' => Common::SOFT_ABSOLUTE_PATH,
      'PassEnvironment' => { kind_of: [String, Array] },
      'StandardInput' => {
        kind_of: String,
        equal_to: %w( null tty tty-force tty-fail socket )
      },
      'StandardOutput' => {
        kind_of: String,
        equal_to: %w(
          inherit
          null
          tty
          journal
          syslog
          kmsg
          journal+console
          syslog+console
          kmsg+console
          socket
        )
      },
      'StandardError' => {
        kind_of: String,
        equal_to: %w(
          inherit
          null
          tty
          journal
          syslog
          kmsg
          journal+console
          syslog+console
          kmsg+console
          socket
        )
      },
      'TTYPath' => Common::ABSOLUTE_PATH,
      'TTYReset' => Common::BOOLEAN,
      'TTYVHangup' => Common::BOOLEAN,
      'TTYVTDisallocate' => Common::BOOLEAN,
      'SyslogIdentifier' => Common::STRING,
      'SyslogFacility' => {
        kind_of: String,
        equal_to: %w(
          kern
          user
          mail
          daemon
          auth
          syslog
          lpr
          news
          uucp
          cron
          authpriv
          ftp
          local0
          local1
          local2
          local3
          local4
          local5
          local6
          local7
        )
      },
      'SyslogLevel' => {
        kind_of: String,
        equal_to: %w( emerg alert crit err warning notice info debug )
      },
      'SyslogLevelPrefix' => Common::BOOLEAN,
      'TimerSlackNSec' => Common::STRING_OR_INT,
      'LimitCPU' => Common::STRING_OR_INT,
      'LimitFSIZE' => Common::STRING_OR_INT,
      'LimitDATA' => Common::STRING_OR_INT,
      'LimitSTACK' => Common::STRING_OR_INT,
      'LimitCORE' => Common::STRING_OR_INT,
      'LimitRSS' => Common::STRING_OR_INT,
      'LimitNOFILE' => Common::STRING_OR_INT,
      'LimitAS' => Common::STRING_OR_INT,
      'LimitNPROC' => Common::STRING_OR_INT,
      'LimitMEMLOCK' => Common::STRING_OR_INT,
      'LimitLOCKS' => Common::STRING_OR_INT,
      'LimitSIGPENDING' => Common::STRING_OR_INT,
      'LimitMSGQUEUE' => Common::STRING_OR_INT,
      'LimitNICE' => Common::STRING_OR_INT,
      'LimitRTPRIO' => Common::STRING_OR_INT,
      'LimitRTTIME' => Common::STRING_OR_INT,
      'PAMName' => Common::STRING,
      'CapabilityBoundingSet' => Common::CAP,
      'AmbientCapabilities' => Common::CAP,
      'SecureBits' => {
        kind_of: [String, Array],
        callbacks: {
          'contains only supported values' => lambda do |spec|
            Array(spec).all? do |s|
              s.empty? || %w(
                keep-caps
                keep-caps-locked
                no-setuid-fixup
                no-setuid-fixup-locked
                noroot
                noroot-locked
              ).include?(s)
            end
          end
        }
      },
      'ReadWriteDirectories' => Common::ARRAY_OF_ABSOLUTE_PATHS,
      'ReadOnlyDirectories' => Common::ARRAY_OF_SOFT_ABSOLUTE_PATHS,
      'InaccessibleDirectories' => Common::ARRAY_OF_SOFT_ABSOLUTE_PATHS,
      'PrivateTmp' => Common::BOOLEAN,
      'PrivateDevices' => Common::BOOLEAN,
      'PrivateNetwork' => Common::BOOLEAN,
      'ProtectSystem' => {
        kind_of: [TrueClass, FalseClass, String],
        equal_to: [true, false, 'full']
      },
      'ProtectHome' => {
        kind_of: [TrueClass, FalseClass, String],
        equal_to: [true, false, 'read-only']
      },
      'MountFlags' => {
        kind_of: String,
        equal_to: %w( shared slave private )
      },
      'UtmpIdentifier' => Common::STRING,
      'UtmpMode' => {
        kind_of: String,
        equal_to: %w( init login user )
      },
      'SELinuxContext' => Common::STRING,
      'AppArmorProfile' => Common::STRING,
      'SmackProcessLabel' => Common::STRING,
      'IgnoreSIGPIPE' => Common::BOOLEAN,
      'NoNewPrivileges' => Common::BOOLEAN,
      'SystemCallFilter' => Common::STRING_OR_ARRAY,
      'SystemCallErrorNumber' => Common::STRING,
      'SystemCallArchitectures' => Common::ARCH,
      'RestrictAddressFamilies' => Common::STRING_OR_ARRAY,
      'Personality' => Common::ARCH,
      'RuntimeDirectory' => {
        kind_of: [String, Array],
        callbacks: {
          'only simple, relative paths' => lambda do |spec|
            Array(spec).all? { |p| !p.include?('/') }
          end
        }
      },
      'RuntimeDirectoryMode' => Common::STRING,
    }.freeze
  end

  module Kill
    OPTIONS ||= {
      'KillMode' => {
        kind_of: String,
        equal_to: %w( control-group process mixed none )
      },
      'KillSignal' => Common::STRING_OR_INT,
      'SendSIGHUP' => Common::BOOLEAN,
      'SendSIGKILL' => Common::BOOLEAN
    }.freeze
  end

  module ResourceControl
    OPTIONS ||= {
      'CPUAccounting' => Common::BOOLEAN,
      'CPUShares' => {
        kind_of: Integer,
        equal_to: 2.upto(262_144).to_a
      },
      'StartupCPUShares' => {
        kind_of: Integer,
        equal_to: 2.upto(262_144).to_a
      },
      'CPUQuota' => {
        kind_of: String,
        callbacks: {
          'is a percentage' => lambda do |spec|
            spec.end_with?(%) && spec.gsub(/%$/, '').match(/^\d+$/)
          end
        }
      },
      'MemoryAccounting' => Common::BOOLEAN,
      'MemoryLimit' => Common::STRING_OR_INT,
      'TasksAccounting' => Common::BOOLEAN,
      'TasksMax' => {
        kind_of: [String, Integer],
        callbacks: {
          'is an integer or "infinity"' => lambda do |spec|
            spec.is_a?(Integer) || spec == 'infinity'
          end
        }
      },
      'IOAccounting' => Common::BOOLEAN,
      'IOWeight' => {
        kind_of: Integer,
        equal_to: 1.upto(10_000).to_a
      },
      'StartupIOWeight' => {
        kind_of: Integer,
        equal_to: 1.upto(10_000).to_a
      },
      'IODeviceWeight' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute? &&
              1.upto(10_000).include?(args[1].to_i)
        }
      },
      'IOReadBandwidthMax' => Common::STRING_OR_INT,
      'IOWriteBandwidthMax' => Common::STRING_OR_INT,
      'IOReadIOPSMax' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute?
          end
        }
      },
      'IOWriteIOPSMax' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute?
          end
        }
      },
      'BlockIOAccounting' => Common::BOOLEAN,
      'BlockIOWeight' => {
        kind_of: Integer,
        equal_to: 10.upto(1_000).to_a,
      },
      'StartupBlockIOWeight' => {
        kind_of: Integer,
        equal_to: 10.upto(1_000).to_a,
      },
      'BlockIODeviceWeight' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute? &&
              10.upto(1_000).include?(args[1].to_i)
        }
      },
      'BlockIOReadBandwidth' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute?
          end
        }
      },
      'BlockIOWriteBandwidth' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute?
          end
        }
      },
      'DeviceAllow' => {
        kind_of: String,
        callbacks: {
          'is a valid argument' => lambda do |spec|
            args = spec.split(' ')
            args.length == 2 &&
              Pathname.new(args[0]).absolute? &&
              %w( r w m ).include?(args[1])
          end
        }
      },
      'DevicePolicy' => { kind_of: String, equal_to: %w( strict auto closed ) },
      'Slice' => {
        kind_of: String,
        callbacks: {
          'is a slice' => -> (spec) { spec.end_with?('.slice') }
        }
      },
      'Delegate' => Common::BOOLEAN,
    }.freeze
  end

  module Automount
    OPTIONS ||= {
      'Automount' => {
        'Where' => {
          kind_of: String,
          required: true,
          callbacks: {
            'is an absolute path' => -> (spec) { Pathname.new(spec).absolute? }
          }
        },
        'DirectoryMode' => Common::STRING,
        'TimeoutIdleSec' => Common::STRING_OR_INT,
      }
    }.freeze
  end

  module Device
    UDEV_PROPERTIES ||= %w(
      SYSTEMD_WANTS
      SYSTEMD_USER_WANTS
      SYSTEMD_ALIAS
      SYSTEMD_READY
      ID_MODEL_FROM_DATABASE
      ID_MODEL
    )
  end

  module Mount
    OPTIONS ||= {
      'Mount' => {
        'What' => {
          kind_of: String,
          required: true,
          callbacks: { 'absolute path' => -> (s) { Pathname.new(s).absolute? }
        },
        'Where' => {
          kind_of: String,
          required: true,
          callbacks: { 'absolute path' => -> (s) { Pathname.new(s).absolute? }
        },
        'Type' => Common::STRING,
        'Options' => Common::STRING,
        'SloppyOptions' => Common::BOOLEAN,
        'DirectoryMode' => Common::STRING,
        'TimeoutSec' => Common::STRING_OR_INT,
      }.merge(Exec::OPTIONS)
       .merge(Kill::OPTIONS)
       .merge(ResourceControl::OPTIONS) 
    }.freeze
  end

  module Path
    OPTIONS ||= {
      'PathExists' => Common::ABSOLUTE_PATH,
      'PathExistsGlob' => Common::ABSOLUTE_PATH,
      'PathChanged' => Common::ABSOLUTE_PATH,
      'PathModified' => Common::ABSOLUTE_PATH,
      'DirectoryNotEmpty' => Common::ABSOLUTE_PATH,
      'Unit' => Common::UNIT,
      'MakeDirectory' => Common::BOOLEAN,
      'DirectoryMode' => Common::STRING
    }.freeze
  end

  module Scope
    OPTIONS ||= { 'Scope' => ResourceControl::OPTIONS }.freeze
  end

  module Service
    OPTIONS ||= {
      'Service' => {
        'Type' => {
          kind_of: String,
          equal_to: %w( simple forking oneshot dbus notify idle )
        },
        'RemainAfterExit' => Common::BOOLEAN,
        'GuessMainPID' => Common::BOOLEAN,
        'PIDFile' => Common::ABSOLUTE_PATH,
        'BusName' => Common::STRING,
        'ExecStart' => Common::STRING,
        'ExecStartPre' => Common::STRING,
        'ExecStartPost' => Common::STRING,
        'ExecReload' => Common::STRING,
        'ExecStop' => Common::STRING,
        'ExecStopPost' => Common::STRING,
        'RestartSec' => Common::STRING_OR_INT,
        'TimeoutStartSec' => Common::STRING_OR_INT,
        'TimeoutStopSec' => Common::STRING_OR_INT,
        'TimeoutSec' => Common::STRING_OR_INT,
        'RuntimeMaxSec' => Common::STRING_OR_INT,
        'WatchdogSec' => Common::STRING_OR_INT,
        'Restart' => {
          kind_of: String,
          equal_to: %w( no on-success on-failure on-abnormal on-watchdog on-abort always )
        },
        'SuccessExitStatus' => { kind_of: [String, Array, Integer] },
        'RestartPreventExitStatus' => { kind_of: [String, Array, Integer] },
        'RestartForceExitStatus' => { kind_of: [String, Array, Integer] },
        'PermissionsStartOnly' => Common::BOOLEAN,
        'RootDirectoryStartOnly' => Common::BOOLEAN,
        'NonBlocking' => Common::BOOLEAN,
        'NotifyAccess' => { kind_of: String, equal_to: %w( none main all ) },
        'Sockets' => Common::ARRAY_OF_UNITS,
        'FailureAction' => Common::POWER,
        'FileDescriptorStoreMax' => Common::INTEGER,
        'USBFunctionDescriptors' => Common::STRING,
        'USBFunctionStrings' => Common::STRING
      }.merge(Exec::OPTIONS)
       .merge(Kill::OPTIONS)
       .merge(ResourceControl::OPTIONS)
    }.freeze
  end

  module Slice
    OPTIONS ||= { 'Slice' => ResourceControl::OPTIONS }.freeze
  end

  module Socket

  end

  module Swap

  end

  module Target

  end

  module Timer

  end
end
