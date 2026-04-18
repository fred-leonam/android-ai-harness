package com.thoughtworks.productssearch.ui

import app.cash.turbine.test
import com.thoughtworks.productssearch.Product
import com.thoughtworks.productssearch.ProductService
import com.thoughtworks.productssearch.Result
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SearchViewModelTest {

    private val testDispatcher = StandardTestDispatcher()
    private lateinit var productService: ProductService
    private lateinit var viewModel: SearchViewModel

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        productService = mockk()
        viewModel = SearchViewModel(productService)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `initial state is empty`() {
        val state = viewModel.uiState.value
        assertEquals("", state.query)
        assertFalse(state.isLoading)
        assertTrue(state.products.isEmpty())
        assertNull(state.error)
        assertFalse(state.hasSearched)
    }

    @Test
    fun `onQueryChange updates query in state`() {
        viewModel.onQueryChange("laptop")
        assertEquals("laptop", viewModel.uiState.value.query)
    }

    @Test
    fun `search success updates products`() = runTest {
        val products = listOf(Product("1", "Laptop", 999.99))
        coEvery { productService.searchProducts("laptop") } returns Result.Success(products)

        viewModel.onQueryChange("laptop")

        viewModel.uiState.test {
            awaitItem() // initial state with query set

            viewModel.search()

            val loadingState = awaitItem()
            assertTrue(loadingState.isLoading)
            assertNull(loadingState.error)
            assertTrue(loadingState.products.isEmpty())

            testDispatcher.scheduler.advanceUntilIdle()

            val successState = awaitItem()
            assertFalse(successState.isLoading)
            assertEquals(products, successState.products)
            assertNull(successState.error)
            assertTrue(successState.hasSearched)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `search error updates error state`() = runTest {
        val exception = IllegalStateException("Simulated search error")
        coEvery { productService.searchProducts("error") } returns Result.Error(exception)

        viewModel.onQueryChange("error")

        viewModel.uiState.test {
            awaitItem() // initial state with query set

            viewModel.search()

            val loadingState = awaitItem()
            assertTrue(loadingState.isLoading)

            testDispatcher.scheduler.advanceUntilIdle()

            val errorState = awaitItem()
            assertFalse(errorState.isLoading)
            assertEquals("Simulated search error", errorState.error)
            assertTrue(errorState.products.isEmpty())
            assertTrue(errorState.hasSearched)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    fun `search with empty results shows hasSearched true and empty list`() = runTest {
        coEvery { productService.searchProducts("xyz") } returns Result.Success(emptyList())

        viewModel.onQueryChange("xyz")

        viewModel.uiState.test {
            awaitItem() // initial state with query set

            viewModel.search()

            val loadingState = awaitItem()
            assertTrue(loadingState.isLoading)

            testDispatcher.scheduler.advanceUntilIdle()

            val emptyState = awaitItem()
            assertFalse(emptyState.isLoading)
            assertTrue(emptyState.products.isEmpty())
            assertNull(emptyState.error)
            assertTrue(emptyState.hasSearched)

            cancelAndIgnoreRemainingEvents()
        }
    }
}
