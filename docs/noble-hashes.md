================
CODE SNIPPETS
================
TITLE: Running Noble-Hashes Benchmarks
DESCRIPTION: This shell command sequence first installs necessary benchmark dependencies (`bench:install`) and then executes the performance benchmarks (`bench`) for the `noble-hashes` library. It's used to measure the speed of various hash functions.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_13

LANGUAGE: sh
CODE:
```
npm run bench:install && npm run bench
```

--------------------------------

TITLE: Building and Testing Noble Hashes
DESCRIPTION: This command sequence is used to set up, build, and run tests for the Noble Hashes library. It first installs dependencies, then compiles the code, and finally executes the test suite to ensure functionality.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_16

LANGUAGE: Shell
CODE:
```
npm install && npm run build && npm test
```

--------------------------------

TITLE: Running Benchmarks for Noble Hashes
DESCRIPTION: This command executes the performance benchmarks for the Noble Hashes library. It measures the speed of various cryptographic operations, providing insights into the library's efficiency. Note that `npm run bench:install` might be needed first for dependencies.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_18

LANGUAGE: Shell
CODE:
```
npm run bench
```

--------------------------------

TITLE: Using BLAKE1, BLAKE2, and BLAKE3 Hashes in TypeScript
DESCRIPTION: This snippet demonstrates the usage of BLAKE1, BLAKE2 (BLAKE2b, BLAKE2s), and BLAKE3 hash functions from `@noble/hashes`. It shows basic hashing with both direct and streaming APIs. Advanced usage examples for BLAKE2 and BLAKE3 are provided, illustrating how to use optional parameters like `key`, `personalization`, `salt`, `dkLen` (derived key length), and `context` to customize the hashing process.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_4

LANGUAGE: TypeScript
CODE:
```
import { blake224, blake256, blake384, blake512 } from '@noble/hashes/blake1.js';
import { blake2b, blake2s } from '@noble/hashes/blake2.js';
import { blake3 } from '@noble/hashes/blake3.js';

for (let hash of [blake224, blake256, blake384, blake512, blake2b, blake2s, blake3]) {
  const arr = Uint8Array.from([0x10, 0x20, 0x30]);
  const a = hash(arr);
  const b = hash.create().update(arr).digest();
}

// blake2 advanced usage
const ab = Uint8Array.from([0x01]);
blake2s(ab);
blake2s(ab, { key: new Uint8Array(32) });
blake2s(ab, { personalization: 'pers1234' });
blake2s(ab, { salt: 'salt1234' });
blake2b(ab);
blake2b(ab, { key: new Uint8Array(64) });
blake2b(ab, { personalization: 'pers1234pers1234' });
blake2b(ab, { salt: 'salt1234salt1234' });

// blake3 advanced usage
blake3(ab);
blake3(ab, { dkLen: 256 });
blake3(ab, { key: new Uint8Array(32) });
blake3(ab, { context: 'application-name' });
```

--------------------------------

TITLE: Running Big Multicore Test for Noble Hashes
DESCRIPTION: This command starts a 2-hour 'big' multicore test for the Noble Hashes library. This extensive test evaluates the library's performance and stability across multiple CPU cores, simulating demanding, long-duration usage scenarios.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_21

LANGUAGE: Shell
CODE:
```
npm run test:big
```

--------------------------------

TITLE: Using SHA2 Hash Functions with Direct and Chained Updates in TypeScript
DESCRIPTION: This TypeScript example illustrates the usage of various SHA2 hash functions, including `sha256`, `sha384`, and `sha512`. It shows both direct hashing of a `Uint8Array` and the more advanced method of creating a hash instance, updating it with data in chunks, and then digesting the result. This demonstrates support for partial updates and chaining.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_1

LANGUAGE: TypeScript
CODE:
```
import { sha224, sha256, sha384, sha512, sha512_224, sha512_256 } from '@noble/hashes/sha2.js';
const res = sha256(Uint8Array.from([0xbc])); // basic
for (let hash of [sha256, sha384, sha512, sha224, sha512_224, sha512_256]) {
  const arr = Uint8Array.from([0x10, 0x20, 0x30]);
  const a = hash(arr);
  const b = hash.create().update(arr).digest();
}
```

--------------------------------

TITLE: Executing All Main Tests (npm)
DESCRIPTION: This command runs the primary test suite for the noble-hashes library, covering general functionality and ensuring core hash functions work as expected.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/test/README.md#_snippet_0

LANGUAGE: Shell
CODE:
```
npm run test
```

--------------------------------

TITLE: Building Single File Release for Noble Hashes
DESCRIPTION: This command compiles the Noble Hashes library into a single, optimized file for release. This is useful for deployment scenarios where a consolidated file is preferred, simplifying distribution and integration.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_19

LANGUAGE: Shell
CODE:
```
npm run build:release
```

--------------------------------

TITLE: Executing Large Input & Scrypt Combination Tests (npm)
DESCRIPTION: This command performs extensive tests, including hashing on 4GiB inputs and scrypt with 1024 different N, r, p combinations. It is a very long-running test, potentially taking several hours, and benefits from multi-core CPUs.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/test/README.md#_snippet_2

LANGUAGE: Shell
CODE:
```
npm run test-big
```

--------------------------------

TITLE: Executing DoS Vulnerability Tests (npm)
DESCRIPTION: This command initiates tests specifically designed to check for Denial-of-Service vulnerabilities by measuring function formulas. It is a long-running test, taking approximately one hour to complete.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/test/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
npm run test-dos
```

--------------------------------

TITLE: Linting and Formatting Noble Hashes Code
DESCRIPTION: These commands are used for maintaining code quality and consistency within the Noble Hashes project. `npm run lint` identifies potential errors and style issues, while `npm run format` automatically fixes formatting problems according to predefined rules.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_17

LANGUAGE: Shell
CODE:
```
npm run lint
```

LANGUAGE: Shell
CODE:
```
npm run format
```

--------------------------------

TITLE: Running DoS Test for Noble Hashes
DESCRIPTION: This command initiates a 20-minute Denial-of-Service (DoS) test for the Noble Hashes library. This specialized test helps ensure the library's resilience and stability under sustained, potentially abusive, load conditions.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_20

LANGUAGE: Shell
CODE:
```
npm run test:dos
```

--------------------------------

TITLE: Benchmarking KDF Performance in Noble Hashes (Pure-JS)
DESCRIPTION: This snippet shows benchmark results for various Key Derivation Functions (KDFs) implemented in the Noble Hashes library. It provides operations per second and time per operation for hkdf, blake3, pbkdf2, scrypt, and argon2id, highlighting their relative performance in a pure JavaScript context.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_14

LANGUAGE: Shell
CODE:
```
# KDF
hkdf(sha256) x 259,942 ops/sec @ 3μs/op
blake3(context) x 424,808 ops/sec @ 2μs/op
pbkdf2(sha256, c: 2 ** 18) x 5 ops/sec @ 197ms/op
pbkdf2(sha512, c: 2 ** 18) x 1 ops/sec @ 630ms/op
scrypt(n: 2 ** 18, r: 8, p: 1) x 2 ops/sec @ 400ms/op
argon2id(t: 1, m: 256MB) 2881ms
```

--------------------------------

TITLE: Implementing SHA-3 Addons (cSHAKE, KMAC, K12, M14, TurboSHAKE) in TypeScript
DESCRIPTION: This snippet demonstrates the usage of various SHA-3 addon functions from `@noble/hashes/sha3-addons.js`, including cSHAKE, TurboSHAKE, TupleHash, ParallelHash, KMAC, K12, M14, and KeccakPRG. It shows how to apply personalization strings, domain separation values (D), and keys for different algorithms. It also illustrates the use of `keccakprg` for pseudo-random generation, showing how to feed data and fetch random bytes.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_3

LANGUAGE: TypeScript
CODE:
```
import {
  cshake128, cshake256, k12, m14,
  keccakprg, kmac128, kmac256,
  parallelhash256, tuplehash256,
  turboshake128, turboshake256,
} from '@noble/hashes/sha3-addons.js';
const data = Uint8Array.from([0x10, 0x20, 0x30]);
const ec1 = cshake128(data, { personalization: 'def' });
const ec2 = cshake256(data, { personalization: 'def' });
const et1 = turboshake128(data);
const et2 = turboshake256(data, { D: 0x05 });
// tuplehash(['ab', 'c']) !== tuplehash(['a', 'bc']) !== tuplehash([data])
const et3 = tuplehash256([utf8ToBytes('ab'), utf8ToBytes('c')]);
// Not parallel in JS (similar to blake3 / k12), added for compat
const ep1 = parallelhash256(data, { blockLen: 8 });
const kk = Uint8Array.from([0xca]);
const ek10 = kmac128(kk, data);
const ek11 = kmac256(kk, data);
const ek12 = k12(data);
const ek13 = m14(data);
// pseudo-random generator, first argument is capacity. XKCP recommends 254 bits capacity for 128-bit security strength.
// * with a capacity of 254 bits.
const p = keccakprg(254);
p.feed('test');
const rand1b = p.fetch(1);
```

--------------------------------

TITLE: Using SHA-3, Keccak, and SHAKE Hashes in TypeScript
DESCRIPTION: This snippet demonstrates how to import and use various SHA-3, Keccak, and SHAKE hash functions from `@noble/hashes/sha3.js`. It shows both direct hashing of a `Uint8Array` and the streaming API using `create().update().digest()` for different hash variants like SHA3-224, SHA3-256, SHA3-384, SHA3-512, Keccak-224, Keccak-256, Keccak-384, Keccak-512, SHAKE128, and SHAKE256. SHAKE functions also illustrate the `dkLen` option for desired output length.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_2

LANGUAGE: TypeScript
CODE:
```
import {
  sha3_224, sha3_256, sha3_384, sha3_512,
  keccak_224, keccak_256, keccak_384, keccak_512,
  shake128, shake256,
} from '@noble/hashes/sha3.js';
for (let hash of [
  sha3_224, sha3_256, sha3_384, sha3_512,
  keccak_224, keccak_256, keccak_384, keccak_512,
]) {
  const arr = Uint8Array.from([0x10, 0x20, 0x30]);
  const a = hash(arr);
  const b = hash.create().update(arr).digest();
}
const shka = shake128(Uint8Array.from([0x10]), { dkLen: 512 });
const shkb = shake256(Uint8Array.from([0x30]), { dkLen: 512 });
```

--------------------------------

TITLE: Verifying Noble-Hashes.js Provenance with GitHub CLI
DESCRIPTION: This command uses the GitHub CLI to verify the provenance of the `noble-hashes.js` file, ensuring it was built and released transparently by the specified owner. It helps in validating the supply chain security of the library.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_12

LANGUAGE: sh
CODE:
```
gh attestation verify --owner paulmillr noble-hashes.js
```

--------------------------------

TITLE: Importing and Using SHA256 in JavaScript
DESCRIPTION: This snippet demonstrates how to import the `sha256` hash function from `@noble/hashes/sha2.js` and use it to hash a `Uint8Array`. It also lists various other hash functions, MACs, and KDFs available for import from different sub-modules, highlighting the modularity of the library. The library encourages sub-imports to minimize application size.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_0

LANGUAGE: JavaScript
CODE:
```
// import * from '@noble/hashes'; // Error: use sub-imports, to ensure small app size
import { sha256 } from '@noble/hashes/sha2.js'; // ESM & Common.js
sha256(Uint8Array.from([0xca, 0xfe, 0x01, 0x23])); // returns Uint8Array

// Available modules
import { sha256, sha384, sha512, sha224, sha512_224, sha512_256 } from '@noble/hashes/sha2.js';
import {
  sha3_256, sha3_512,
  keccak_256, keccak_512,
  shake128, shake256,
} from '@noble/hashes/sha3.js';
import {
  cshake256, turboshake256, kmac256, tuplehash256,
  k12, m14, keccakprg,
} from '@noble/hashes/sha3-addons.js';
import { blake3 } from '@noble/hashes/blake3.js';
import { blake2b, blake2s } from '@noble/hashes/blake2.js';
import { blake256, blake512 } from '@noble/hashes/blake1.js';
import { sha1, md5, ripemd160 } from '@noble/hashes/legacy.js';
import { hmac } from '@noble/hashes/hmac.js';
import { hkdf } from '@noble/hashes/hkdf.js';
import { pbkdf2, pbkdf2Async } from '@noble/hashes/pbkdf2.js';
import { scrypt, scryptAsync } from '@noble/hashes/scrypt.js';
import { argon2d, argon2i, argon2id } from '@noble/hashes/argon2.js';
import * as utils from '@noble/hashes/utils'; // bytesToHex, bytesToUtf8, concatBytes...
```

--------------------------------

TITLE: Unrolled Loop for Bitwise XOR Operations in JavaScript
DESCRIPTION: This snippet illustrates the concept of loop unrolling to optimize bitwise XOR operations. Instead of a loop, each operation is explicitly written out, eliminating array access overhead and bound checks, which can significantly improve performance. The `// ...` indicates continuation for other `B` variables.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/benchmark/README.md#_snippet_1

LANGUAGE: JavaScript
CODE:
```
let B0 = s0 ^ s10 ^ s20 ^ s30 ^ s40;
let B1 = s1 ^ s11 ^ s21 ^ s31 ^ s41; // ...
```

--------------------------------

TITLE: Comparing Native Node.js Hash and KDF Performance
DESCRIPTION: This snippet presents benchmark results for cryptographic functions using Node.js's native C bindings. It compares the performance of various hash algorithms (SHA256, SHA512, SHA3_256, BLAKE2b, BLAKE2s, HMAC, HKDF) and KDFs (PBKDF2, Scrypt) against pure-JS implementations, showing the speed advantage of native code.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_15

LANGUAGE: Shell
CODE:
```
# native (node) 32B
sha256 x 2,267,573 ops/sec
sha512 x 983,284 ops/sec
sha3_256 x 1,522,070 ops/sec
blake2b x 1,512,859 ops/sec
blake2s x 1,821,493 ops/sec
hmac(sha256) x 1,085,776 ops/sec
hkdf(sha256) x 312,109 ops/sec
# native (node) KDF
pbkdf2(sha256, c: 2 ** 18) x 5 ops/sec @ 197ms/op
pbkdf2(sha512, c: 2 ** 18) x 1 ops/sec @ 630ms/op
scrypt(n: 2 ** 18, r: 8, p: 1) x 2 ops/sec @ 378ms/op
```

--------------------------------

TITLE: Run-time Loop Unrolling with `new Function` in JavaScript
DESCRIPTION: This snippet demonstrates run-time loop unrolling using `new Function` (eval). It dynamically constructs a string containing unrolled bitwise XOR operations and then creates a new function from this string. This method generates highly optimized code at runtime but is incompatible with CSP policies that disallow `unsafe-eval`.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/benchmark/README.md#_snippet_2

LANGUAGE: JavaScript
CODE:
```
let out = ''
for (let x = 0; x < 10; x++)
 out += `let B${x} = s${x} ^ s${x + 10} ^ s${x + 20} ^ s${x + 30} ^ s${x + 40};\n`;
const UNROLLED_FN = new Function('state', out);
```

--------------------------------

TITLE: Looping Array Access for Bitwise XOR in JavaScript
DESCRIPTION: This snippet demonstrates a standard loop for performing bitwise XOR operations on array elements. It iterates 10 times, calculating a value for `B[x]` by XORing elements from array `s` at specific offsets. This approach is noted as being slow due to array bound checks.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/benchmark/README.md#_snippet_0

LANGUAGE: JavaScript
CODE:
```
for (let x = 0; x < 10; x++)
  B[x] = s[x] ^ s[x+10] ^ s[x+20] ^ s[x+30] ^ s[x+40];
```

--------------------------------

TITLE: Deriving Keys with Argon2 in TypeScript
DESCRIPTION: This snippet demonstrates using Argon2 for password hashing, specifically the argon2id variant, from @noble/hashes/argon2.js. It highlights the configuration parameters t (time cost), m (memory cost), and p (parallelism). A warning is included regarding Argon2's performance limitations in JavaScript environments due to the lack of fast Uint64Array support, suggesting Scrypt as a more performant alternative.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_10

LANGUAGE: TypeScript
CODE:
```
import { argon2d, argon2i, argon2id } from '@noble/hashes/argon2.js';
const arg1 = argon2id('password', 'saltsalt', { t: 2, m: 65536, p: 1, maxmem: 2 ** 32 - 1 });
```

--------------------------------

TITLE: Deriving Keys with Scrypt in TypeScript
DESCRIPTION: This snippet demonstrates using Scrypt for password-based key derivation, available in both synchronous (scrypt) and asynchronous (scryptAsync) versions. It highlights configuring work factors (N, r, p), output key length (dkLen), and advanced options like onProgress for async operations and maxmem for memory control. Scrypt is recommended over Argon2 in JavaScript due to performance considerations and conforms to RFC 7914.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_9

LANGUAGE: TypeScript
CODE:
```
import { scrypt, scryptAsync } from '@noble/hashes/scrypt.js';
const scr1 = scrypt('password', 'salt', { N: 2 ** 16, r: 8, p: 1, dkLen: 32 });
const scr2 = await scryptAsync('password', 'salt', { N: 2 ** 16, r: 8, p: 1, dkLen: 32 });
const scr3 = await scryptAsync(Uint8Array.from([1, 2, 3]), Uint8Array.from([4, 5, 6]), {
  N: 2 ** 17,
  r: 8,
  p: 1,
  dkLen: 32,
  onProgress(percentage) {
    console.log('progress', percentage);
  },
  maxmem: 2 ** 32 + 128 * 8 * 1 // N * r * p * 128 + (128*r*p)
});
```

--------------------------------

TITLE: Using Utility Functions in Noble Hashes (TypeScript)
DESCRIPTION: This snippet showcases common utility functions from @noble/hashes/utils.js. It demonstrates bytesToHex for converting a Uint8Array to its hexadecimal string representation and randomBytes for generating cryptographically secure random byte arrays of a specified length. These utilities are essential for handling cryptographic data formats.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_11

LANGUAGE: TypeScript
CODE:
```
import { bytesToHex as toHex, randomBytes } from '@noble/hashes/utils';
console.log(toHex(randomBytes(32)));
```

--------------------------------

TITLE: Using Legacy Hash Functions (SHA-1, MD5, RIPEMD160) in TypeScript
DESCRIPTION: This snippet demonstrates how to import and use legacy hash functions like MD5, RIPEMD160, and SHA-1 from `@noble/hashes/legacy.js`. It shows both the direct hashing method and the streaming API (`create().update().digest()`) for these algorithms. The accompanying text warns against using these 'weak' hash functions in new protocols due to known collision vulnerabilities, though HMAC usage with them is noted as potentially acceptable.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_5

LANGUAGE: TypeScript
CODE:
```
import { md5, ripemd160, sha1 } from '@noble/hashes/legacy.js';
for (let hash of [md5, ripemd160, sha1]) {
  const arr = Uint8Array.from([0x10, 0x20, 0x30]);
  const a = hash(arr);
  const b = hash.create().update(arr).digest();
}
```

--------------------------------

TITLE: Deriving Keys with PBKDF2 in TypeScript
DESCRIPTION: This snippet illustrates the use of PBKDF2 (Password-Based Key Derivation Function 2) from @noble/hashes/pbkdf2.js. It shows both synchronous (pbkdf2) and asynchronous (pbkdf2Async) key derivation, supporting string and Uint8Array inputs for password and salt. PBKDF2 is commonly used for hashing passwords and conforms to RFC 2898.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_8

LANGUAGE: TypeScript
CODE:
```
import { pbkdf2, pbkdf2Async } from '@noble/hashes/pbkdf2.js';
import { sha256 } from '@noble/hashes/sha2.js';
const pbkey1 = pbkdf2(sha256, 'password', 'salt', { c: 32, dkLen: 32 });
const pbkey2 = await pbkdf2Async(sha256, 'password', 'salt', { c: 32, dkLen: 32 });
const pbkey3 = await pbkdf2Async(sha256, Uint8Array.from([1, 2, 3]), Uint8Array.from([4, 5, 6]), {
  c: 32,
  dkLen: 32,
});
```

--------------------------------

TITLE: Deriving Keys with HKDF in TypeScript
DESCRIPTION: This snippet demonstrates how to use the HKDF (HMAC-based Key Derivation Function) from @noble/hashes/hkdf.js. It shows both the single-step hkdf function and the two-step extract and expand process, which are equivalent. HKDF is used to derive cryptographic keys from a master key and salt, conforming to RFC 5869.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_7

LANGUAGE: TypeScript
CODE:
```
import { hkdf } from '@noble/hashes/hkdf.js';
import { randomBytes } from '@noble/hashes/utils.js';
import { sha256 } from '@noble/hashes/sha2.js';
const inputKey = randomBytes(32);
const salt = randomBytes(32);
const info = 'application-key';
const hk1 = hkdf(sha256, inputKey, salt, info, 32);

// == same as
import { extract, expand } from '@noble/hashes/hkdf.js';
import { sha256 } from '@noble/hashes/sha2.js';
const prk = extract(sha256, inputKey, salt);
const hk2 = expand(sha256, prk, info, 32);
```

--------------------------------

TITLE: Implementing HMAC with SHA256 in TypeScript
DESCRIPTION: This snippet demonstrates how to compute a Hash-based Message Authentication Code (HMAC) using the `hmac` function from `@noble/hashes/hmac.js` with SHA256 as the underlying hash function. It shows two methods: direct computation with `hmac(sha256, key, msg)` and a streaming approach using `hmac.create(sha256, key).update(msg).digest()`. It requires a secret `key` and the `message` to be authenticated, both as `Uint8Array`.

SOURCE: https://github.com/paulmillr/noble-hashes/blob/main/README.md#_snippet_6

LANGUAGE: TypeScript
CODE:
```
import { hmac } from '@noble/hashes/hmac.js';
import { sha256 } from '@noble/hashes/sha2.js';
const key = new Uint8Array(32).fill(1);
const msg = new Uint8Array(32).fill(2);
const mac1 = hmac(sha256, key, msg);
const mac2 = hmac.create(sha256, key).update(msg).digest();
```