#include "MT19937Wrapper.hpp"
#include <random>

struct mt19937_64_impl {
  
  explicit mt19937_64_impl(uint32_t s): gen_(s){}
  
  uint64_t next_u64() {
    return gen_();
  }
  
  void discard(uint64_t z) {
    gen_.discard(z);
  }
  
private:
  std::mt19937_64 gen_;
};

mt19937_64* mt19937_64_create(uint32_t seed)
{
  mt19937_64* result = new mt19937_64();
  result->handle = new mt19937_64_impl(seed);
  return result;
}

void mt19937_64_destroy(mt19937_64* h)
{
  delete h->handle;
  delete h;
}

uint64_t mt19937_64_next_u64(mt19937_64* h)
{
  return h->handle->next_u64();
}

void mt19937_64_discard(mt19937_64 *h, uint64_t z)
{
  h->handle->discard(z);
}
