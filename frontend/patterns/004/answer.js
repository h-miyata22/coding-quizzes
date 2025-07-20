function createValidatedObject(schema) {
  const data = {};
  
  return new Proxy(data, {
    get(target, property) {
      if (property in schema) {
        return target[property];
      }
      throw new Error(`プロパティ ${String(property)} は定義されていません`);
    },
    
    set(target, property, value) {
      if (!(property in schema)) {
        throw new Error(`プロパティ ${String(property)} は定義されていません`);
      }
      
      const { validate, message } = schema[property];
      
      if (!validate(value)) {
        throw new Error(message || `プロパティ ${String(property)} の値が不正です`);
      }
      
      target[property] = value;
      return true;
    },
    
    has(target, property) {
      return property in schema;
    },
    
    ownKeys(target) {
      return Object.keys(schema);
    },
    
    getOwnPropertyDescriptor(target, property) {
      if (property in schema) {
        return {
          enumerable: true,
          configurable: true,
          value: target[property]
        };
      }
      return undefined;
    }
  });
}