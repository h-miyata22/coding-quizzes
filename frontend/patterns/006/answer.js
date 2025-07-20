function createImmutable(object) {
  const mutatingArrayMethods = [
    'push', 'pop', 'shift', 'unshift', 'splice',
    'sort', 'reverse', 'fill', 'copyWithin'
  ];

  function makeImmutable(obj) {
    if (typeof obj !== 'object' || obj === null) {
      return obj;
    }

    return new Proxy(obj, {
      get(target, property) {
        const value = target[property];
        
        // 配列の破壊的メソッドをインターセプト
        if (Array.isArray(target) && mutatingArrayMethods.includes(property)) {
          return function() {
            throw new Error(`Cannot call method ${property}. Array is immutable.`);
          };
        }
        
        // ネストしたオブジェクトも不変にする
        if (typeof value === 'object' && value !== null) {
          return makeImmutable(value);
        }
        
        return value;
      },
      
      set(target, property, value) {
        if (property in target) {
          throw new Error(`Cannot modify property ${String(property)}. Object is immutable.`);
        } else {
          throw new Error(`Cannot add property ${String(property)}. Object is immutable.`);
        }
      },
      
      deleteProperty(target, property) {
        throw new Error(`Cannot delete property ${String(property)}. Object is immutable.`);
      },
      
      defineProperty(target, property) {
        throw new Error(`Cannot define property ${String(property)}. Object is immutable.`);
      },
      
      setPrototypeOf(target) {
        throw new Error('Cannot change prototype. Object is immutable.');
      },
      
      preventExtensions(target) {
        return false;
      },
      
      isExtensible(target) {
        return false;
      }
    });
  }

  return makeImmutable(object);
}