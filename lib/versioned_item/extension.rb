module VersionedItem
  module Extension
    extend self

    def [](version)
      raise VersionsNotConfigured if available_versions.empty?
      raise VersionNotFound unless available_versions.include? version.to_s

      resolve_class(version.to_s)
    end

    private

    def resolve_class(version)
      namespace, name = split_namespace
      class_name = "#{namespace}::#{version_to_namespace(version)}::#{name}"

      if class_map[class_name]
        class_map[class_name]
      elsif const_defined? class_name
        class_map[class_name] = Object.const_get class_name, false
      else
        class_map[class_name] = resolve_class(prev_version(version))
      end
    end

    # 1.1 => V1_1
    # v1.1 => V1_1
    # v2.5.alpha6 => V2_5_alpha6
    def version_to_namespace(version)
      version.tr('.', '_').capitalize.tap do |v|
        v.prepend('V') unless v[0] == 'V'
      end
    end

    def const_defined?(name)
      Object.const_get(name, false)
      true
    rescue NameError
      false
    end

    def prev_version(version)
      available_versions.each_cons(2) do |prev, cur|
        return prev if cur == version
      end
      raise ItemNotFound
    end

    def available_versions
      VersionedItem.available_versions
    end

    def class_map
      VersionedItem.class_map
    end

    def split_namespace
      namespace, _, demodulized = name.rpartition '::'
      namespace = 'Object' if namespace.empty?

      [namespace, demodulized]
    end
  end
end
