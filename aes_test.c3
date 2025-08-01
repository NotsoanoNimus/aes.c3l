module crypto::aes_test;


import crypto::aes;
import std::io;

struct TestCase
{
	AesKey aes;
	char[] key;
	char[] plaintext;
	char[] cipher;
}

fn void test_ecb_encrypt() @test
{
	char[16] out;
	TestCase[] tests = {
		{
			.aes = aes::AES128,
			.key = x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext = x"6bc1bee22e409f96e93d7e117393172a",
			.cipher = x"3ad77bb40d7a3660a89ecaf32466ef97",
		},
		{
			.aes = aes::AES128,
			.key = x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext = x"ae2d8a571e03ac9c9eb76fac45af8e51",
			.cipher = x"f5d3d58503b9699de785895a96fdbaaf",
		},
		{
			.aes = aes::AES128,
			.key = x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext = x"30c81c46a35ce411e5fbc1191a0a52ef",
			.cipher = x"43b1cd7f598ece23881b00e3ed030688",
		},
		{
			.aes = aes::AES128,
			.key = x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext = x"f69f2445df4f9b17ad2b417be66c3710",
			.cipher = x"7b0c785e27e8ad3f8223207104725dd4",
		},
		{
			.aes = aes::AES192,
    			.key = x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
			.plaintext = x"6bc1bee22e409f96e93d7e117393172a",
			.cipher = x"bd334f1d6e45f25ff712a214571fa5cc",
		},
		{
			.aes = aes::AES256,
    			.key = x"603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
			.plaintext = x"6bc1bee22e409f96e93d7e117393172a",
    			.cipher = x"f3eed1bdb5d2a03c064b5a7e3db181f8",
		},
	};

	AesCtx ctx;
	foreach (i, t : tests)
	{
		ctx.init(t.aes, t.key);
		ecb::encrypt_buffer(&ctx, t.plaintext, &out);
		assert(out[:16] == t.cipher[:16],
			"Test %d failed; invalid cipher; got: %s, want: %s", i+1, out, t.cipher);

	}

	foreach (i, t : tests)
	{
		@pool()
		{
			ctx.init(t.aes, t.key);
			char[] tmp_out = ecb::encrypt_temp(&ctx, t.plaintext);
			assert(tmp_out[:16] == t.cipher[:16],
				"Test %d failed; invalid cipher; got: %s, want: %s", i+1, tmp_out, t.cipher);
		};
	}
}

fn void test_ecb_decrypt() @test
{
	char[16] out;
	TestCase[] tests = {
		{
			.aes 		= aes::AES128,
			.key 		= x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172a",
			.cipher 	= x"3ad77bb40d7a3660a89ecaf32466ef97",
		},
		{
			.aes 		= aes::AES192,
			.key 		= x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172a",
			.cipher 	= x"bd334f1d6e45f25ff712a214571fa5cc",
		},
		{
			.aes 		= aes::AES256,
			.key 		= x"603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172a",
			.cipher 	= x"f3eed1bdb5d2a03c064b5a7e3db181f8",
		},
	};

	AesCtx ctx;
	foreach (i, t : tests)
	{
		ctx.init(t.aes, t.key);
		ecb::decrypt_buffer(&ctx, t.cipher, &out);
		assert(out[:16] == t.plaintext[:16],
			"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, out, t.plaintext);
	}

	foreach (i, t : tests)
	{
		@pool()
		{
			ctx.init(t.aes, t.key);
			char[] tmp_out = ecb::decrypt_temp(&ctx, t.cipher);
			assert(tmp_out[:16] == t.plaintext[:16],
				"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, tmp_out, t.plaintext);
		};
	}
}

fn void test_cbc_encrypt() @test
{
	char[64] out;
	TestCase[] tests = {
		{
			.aes 		= aes::AES128,
			.key 		= x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"7649abac8119b246cee98e9b12e9197d5086cb9b507219ee95db113a917678b273bed6b8e3c1743b7116e69e222295163ff1caa1681fac09120eca307586e1a7",
    		},
		{
			.aes 		= aes::AES192,
			.key 		= x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"4f021db243bc633d7178183a9fa071e8b4d9ada9ad7dedf4e5e738763f69145a571b242012fb7ae07fa9baac3df102e008b0e27988598881d920a9e64f5615cd",
		},
		{
			.aes 		= aes::AES256,
			.key 		= x"603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"f58c4c04d6e5f1ba779eabfb5f7bfbd69cfc4e967edb808d679f777bc6702c7d39f23369a9d9bacfa530e26304231461b2eb05e2c39be9fcda6c19078c6a9d1b",
		},
	};
    	char[] iv = x"000102030405060708090a0b0c0d0e0f";

	AesCtx ctx;
	foreach (i, t : tests)
	{
		ctx.init_with_iv(t.aes, t.key, iv);
		cbc::encrypt_buffer(&ctx, t.plaintext, &out);
		assert(out[:64] == t.cipher[:64],
			"Test %d failed; invalid cipher; got: %s, want: %s", i+1, out, t.cipher);
	}

	foreach (i, t : tests)
	{
		@pool()
		{
			ctx.init_with_iv(t.aes, t.key, iv);
			char[] tmp_out = cbc::encrypt_temp(&ctx, t.plaintext);
			assert(tmp_out[:64] == t.cipher[:64],
				"Test %d failed; invalid cipher; got: %s, want: %s", i+1, tmp_out, t.cipher);
		};
	}
}

fn void test_cbc_decrypt() @test
{
	char[64] out;
	TestCase[] tests = {
		{
			.aes 		= aes::AES128,
			.key 		= x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"7649abac8119b246cee98e9b12e9197d5086cb9b507219ee95db113a917678b273bed6b8e3c1743b7116e69e222295163ff1caa1681fac09120eca307586e1a7",
    		},
		{
			.aes 		= aes::AES192,
			.key 		= x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"4f021db243bc633d7178183a9fa071e8b4d9ada9ad7dedf4e5e738763f69145a571b242012fb7ae07fa9baac3df102e008b0e27988598881d920a9e64f5615cd",
		},
		{
			.aes 		= aes::AES256,
			.key 		= x"603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"f58c4c04d6e5f1ba779eabfb5f7bfbd69cfc4e967edb808d679f777bc6702c7d39f23369a9d9bacfa530e26304231461b2eb05e2c39be9fcda6c19078c6a9d1b",
		},
	};
    	char[] iv = x"000102030405060708090a0b0c0d0e0f";

	AesCtx ctx;
	foreach (i, t : tests)
	{
		ctx.init_with_iv(t.aes, t.key, iv);
		cbc::decrypt_buffer(&ctx, t.cipher, &out);
		assert(out[:64] == t.plaintext[:64],
			"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, out, t.plaintext);
	}

	foreach (i, t : tests)
	{
		@pool()
		{
			ctx.init_with_iv(t.aes, t.key, iv);
			char[] tmp_out = cbc::decrypt_temp(&ctx, t.cipher);
			assert(tmp_out[:64] == t.plaintext[:64],
				"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, tmp_out, t.plaintext);
		};
	}
}

fn void test_ctr_xcrypt() @test
{
	char[64] out;
	TestCase[] tests = {
		{
			.aes 		= aes::AES128,
			.key 		= x"2b7e151628aed2a6abf7158809cf4f3c",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"874d6191b620e3261bef6864990db6ce9806f66b7970fdff8617187bb9fffdff5ae4df3edbd5d35e5b4f09020db03eab1e031dda2fbe03d1792170a0f3009cee",
    		},
		{
			.aes 		= aes::AES192,
			.key 		= x"8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"1abc932417521ca24f2b0459fe7e6e0b090339ec0aa6faefd5ccc2c6f4ce8e941e36b26bd1ebc670d1bd1d665620abf74f78a7f6d29809585a97daec58c6b050",
		},
		{
			.aes 		= aes::AES256,
			.key 		= x"603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
			.plaintext 	= x"6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
			.cipher 	= x"601ec313775789a5b7a7f504bbf3d228f443e3ca4d62b59aca84e990cacaf5c52b0930daa23de94ce87017ba2d84988ddfc9c58db67aada613c2dd08457941a6",
    		},
	};
    	char[] iv = x"f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff";

	AesCtx ctx;
	foreach (i, t : tests)
	{
		// encrypt
		ctx.init_with_iv(t.aes, t.key, iv);
		ctr::encrypt_buffer(&ctx, t.plaintext, &out);
		assert(out[:64] == t.cipher[:64],
			"Test %d failed; invalid cipher; got: %s, want: %s", i+1, out, t.cipher);

		// decrypt
		ctx.init_with_iv(t.aes, t.key, iv);
		ctr::decrypt_buffer(&ctx, t.cipher, &out);
		assert(out[:64] == t.plaintext[:64],
			"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, out, t.plaintext);
	}
	foreach (i, t : tests)
	{
		@pool()
		{
			// encrypt
			ctx.init_with_iv(t.aes, t.key, iv);
			char[] cipher = ctr::encrypt_temp(&ctx, t.plaintext);
			assert(cipher[:64] == t.cipher[:64],
				"Test %d failed; invalid cipher; got: %s, want: %s", i+1, cipher, t.cipher);

			// decrypt
			ctx.init_with_iv(t.aes, t.key, iv);
			char[] text = ctr::decrypt_temp(&ctx, t.cipher);
			assert(text[:64] == t.plaintext[:64],
				"Test %d failed; invalid plaintext; got: %s, want: %s", i+1, text, t.plaintext);
		};
	}
}

