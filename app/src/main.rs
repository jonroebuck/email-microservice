use warp::Filter;
use tokio::signal;

#[tokio::main]
async fn main() {
    // Define a route that returns "hello world"
    let hello = warp::path::end()
        .map(|| warp::reply::html("hello world"));

    // Start the warp server on localhost:8080
    let (addr, server) = warp::serve(hello)
        .bind_with_graceful_shutdown(([0, 0, 0, 0], 8080), async {
            signal::ctrl_c().await.expect("failed to install Ctrl+C handler");
        });

    println!("Listening on http://{}", addr);

    server.await;
}