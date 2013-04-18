#include "bootpack.h"

#define FLAGS_OVERRUN		0x0001

void fifo32_init(struct FIFO32 *fifo, int size, int *buf)
{
	fifo->size = size;
	fifo->buf = buf;
	fifo->free = size; /* 缓冲区的大小 */
	fifo->flags = 0;
	fifo->p = 0; /* 下一个数据写入位置 */
	fifo->q = 0; /* 下一个数据读出位置 */
	return;
}

int fifo32_put(struct FIFO32 *fifo, int data)
/* FIFO写入数据 */
{
	if (fifo->free == 0) {
		/* 没有空余了 */
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->buf[fifo->p] = data;
	fifo->p++;
	if (fifo->p == fifo->size) {
		fifo->p = 0;
	}
	fifo->free--;
	return 0;
}

int fifo32_get(struct FIFO32 *fifo)
/* FIFO获取一个数据 */
{
	int data;
	if (fifo->free == fifo->size) {
		/* 如果缓冲区为空 */
		return -1;
	}
	data = fifo->buf[fifo->q];
	fifo->q++;
	if (fifo->q == fifo->size) {
		fifo->q = 0;
	}
	fifo->free++;
	return data;
}

int fifo32_status(struct FIFO32 *fifo)
/* 已经存储了多少数据 */
{
	return fifo->size - fifo->free;
}
